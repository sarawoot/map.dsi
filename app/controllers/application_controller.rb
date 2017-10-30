# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :layout_by_resource
  # helper_method :current_user

  def insert_kml(kmlname,name,descr,imgname,loc)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "INSERT INTO kml (kmlname,name,descr,imgname,the_geom) "
    sql += "VALUES('#{kmlname}','#{name}','#{descr}','#{imgname}',geometryfromtext(\'#{loc}\',4326))"
    con.exec(sql)
    con.close
  end

  def generate_kml(layername)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select id,kmlname,name,descr,imgname,astext(the_geom) as geom "
    sql += "FROM kml "
    sql += "WHERE kmlname = '#{layername}' "
    res = con.exec(sql)
    con.close
    
    header = open("#{layername}-header").readlines.join()
    footer = open("#{layername}-footer").readlines.join()

    place = nil
    
    n = 0
    res.each do |rec|
      n += 1
      id = rec['id']
      kmlname = rec['kmlname']
      name = rec['name']
      descr = rec['descr']
      imgname = rec['imgname']
      geom = rec['geom']
      coord = 'NA'
      if geom =~ /POINT/
        ll = geom.split('POINT(').last.split(')').first
        coord = ll.tr(' ',',')
      end

      if (n == 1)
        place =  "        <Placemark>\n"
      else
        place +=  "        <Placemark>\n"
      end
      place += "          <id>#{id}</id>\n"
      place += "          <name>#{name}</name>\n"
      place += "          <styleUrl>#marker</styleUrl>\n"
      place += "          <description>#{descr}</description>\n"

      if (imgname.to_s.length > 0)
        place += "          <imgUrl>http://203.151.201.129/dsix/photos/#{imgname}</imgUrl>\n"
      end
      
      if (geom =~ /POINT/)
        place += "          <Point>\n"
        place += "            <coordinates>#{coord}</coordinates>\n"
        place += "          </Point>\n"
        place += "        </Placemark>\n"
      end    
    end
    kml = header << place << footer
    
    # Write new kml to file
    File.open("../kml/#{layername}.kml","w").write(kml)
  end

  def check_dup(fn)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "SELECT filename FROM photos "
    sql += "WHERE filename = '#{fn}'"
    res = con.exec(sql)
    count = res.num_tuples
    if count == 0
      sql = "INSERT INTO photos (filename) "
      sql += "VALUES ('#{fn}')"
      res = con.exec(sql)
    end
    con.close
    return (count == 0) ? false : true
  end

  def check_records()
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "SELECT * FROM kml "
    res = con.exec(sql)
    found = res.num_tuples
    if (found == 0)
      sql = "ALTER SEQUENCE kml_id_seq RESTART WITH 1"
      res = con.exec(sql)
    end
    con.close
  end

  def dms2dd(dd,mm,ss)
    d = dd.to_f
    m = mm.to_f / 60.0
    s = ss.to_f / 3600.0
    return d + m + s
  end

  def check_npark(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select fr_name from fr_np where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    name = "NA"
    if (found == 1)
      res.each do |rec|
        name = rec['fr_name']
      end
    end
    name
  end

  def check_rforest(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select fr_name from fr_nrf where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    name = "NA"
    if (found == 1)
      res.each do |rec|
        name = rec['fr_name']
      end
    end
    name
  end

  def convert_gcs(n,e,z)
    if z == '47'
      srid = 32647
    else
      srid = 32648
    end

    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "SELECT astext(transform(geometryfromtext('POINT(#{e} #{n})',#{srid}), 4326)) as geom"
    res = con.exec(sql)
    con.close

    #POINT(100.566084211455 13.8907665943153)
    point = res[0]['geom'].to_s.split('(').last.tr(')','').split(' ')
    lon = point.first
    lat = point.last
    return [lon,lat]
  end

  def check_uforest(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select forest_n from use_forest where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    name = "NA"
    if (found == 1)
      name = res[0]['forest_n']
    end
    name
  end

  def log(msg)
    log = open("/tmp/checkUTMIndian.log","a")
    log.write(msg)
    log.write("\n")
    log.close
  end

  def log_search_googlex(msg)
    f = open("/tmp/search-googlex","a")
    f.write(msg)
    f.write("\n")
    f.close
  end

  def create_hili_map(table,gids)

    ##### Start create hilimap according to query with exact = 1
    geom = "POLYGON"
    filter = "gid in (#{gids.join(',')})"
    if table =~ /muban/
      geom = "POINT"
    end

    log_search_googlex("filter: #{filter}")
    src = open('/ms603/map/search.tpl').readlines
    dst = open('/ms603/map/hili.map','w')
    
    src.each do |line|
      if line =~ /XXGEOMXX/
        line = line.gsub(/XXGEOMXX/,"#{geom}")
      elsif line =~ /XXTABLE/
        line = line.gsub(/XXTABLEXX/,"#{table}")
      elsif line =~ /XXFILTERXX/
        line = line.gsub(/XXFILTERXX/,"#{filter}")
      end
      dst.write(line)
    end
    dst.close
    ##### End of create hilight

  end

  def get_center(table,gid)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "SELECT center(the_geom) as centerx "
    sql += "FROM #{table} "
    sql += "WHERE gid=#{gid}"
    
    log_search_googlex("get_center:sql: #{sql}")
    
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    lonlat = []
    if (found == 1)
      res.each do |rec|
        lonlat = rec['centerx'].to_s.tr('()','').split(',')
        lon = sprintf("%0.2f", lonlat[0].to_f)
        lat = sprintf("%0.2f", lonlat[1].to_f)
        lonlat = [lon,lat]
      end
    end
    lonlat
  end

  def search_location(query, start, limit, exact)
    lon = lat = 0.0
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    cond = nil

    if exact == 1
      sql = "SELECT loc_gid,loc_text,loc_table "
      sql += "FROM locations "

      if query =~ /^จ./
        sql += "WHERE loc_text = '#{query}' "
      else
        sql += "WHERE loc_text = '#{query}' LIMIT 1"
      end

      res = con.exec(sql)

      gids = []
      gid = 0
      text = nil
      table = nil
      res.each do |rec|
        gid = rec['loc_gid']
        gids.push(gid)
        text = rec['loc_text']
        table = rec['loc_table']
      end
    
      lonlat = get_center(table,gids[0])
      lon = lonlat[0]
      lat = lonlat[1]  
    
      create_hili_map(table,gids)
    
      return_data = Hash.new
      return_data[:success] = true
      return_data[:totalcount] = 1
      return_data[:records] = [{
        :loc_gid => gid,
        :loc_text => text,
        :loc_table => table,
        :lon => lon, 
        :lat => lat
      }]    
      return return_data
    end
    
    # add space check in query

    if query =~ /\./ and query.strip !~ /\ /     
      cond = "loc_text LIKE '#{query}%' "
    elsif query.to_s.strip =~ /\ /
      kws = query.strip.split(' ')
      (0..kws.length-1).each do |n|
        if n == 0
          if kws[0][1..1] == '.' # ต. อ. จ.
            cond = "loc_text LIKE '#{kws[n]}%' "
          else
            cond = "loc_text LIKE '%#{kws[n]}%' "
          end
        else
          cond += "AND loc_text LIKE '%#{kws[n]}%' "
        end
      end
    else
      cond = "loc_text LIKE '%#{query}%' "
    end

    #log_search_googlex("cond: #{cond}")
    
    sql = "SELECT count(*) as cnt FROM locations WHERE #{cond}" 

    #log_search_googlex("sql: #{sql}")

    res = con.exec(sql)
    found = 0
    res.each do |rec|
      found = rec['cnt'].to_i
    end

    return_data = nil
    
    if (found > 1)
      sql = "SELECT loc_gid,loc_text,loc_table "
      sql += "FROM locations "
      sql += "WHERE #{cond} "
      sql += "ORDER BY id DESC "
      sql += "LIMIT #{limit} OFFSET #{start}"

      #log_search_googlex("sql:found>1: #{sql}")

      res = con.exec(sql)
      records = []
      res.each do |rec|
        gid = rec['loc_gid']
        text = rec['loc_text']
        table = rec['loc_table']
        h = {:loc_gid => "#{gid}", :loc_text => "#{text}", :loc_table => "#{table}"}
        records.push(h)
      end
      
      #log_search_googlex("records[]: #{records}")
      
      return_data = Hash.new
      return_data[:success] = true
      return_data[:totalcount] = found
      return_data[:records] = records
      
    elsif found == 1 # exact != 1
      sql = "SELECT loc_gid,loc_text,loc_table "
      sql += "FROM locations "
      sql += "WHERE loc_text LIKE '#{query}%' "

      #log_search_googlex("sql:found=1: #{sql}")

      res = con.exec(sql)
      gids = []
      gid = 0
      text = nil
      table = nil
      res.each do |rec|
        gid = rec['loc_gid']
        gids.push(gid)
        text = rec['loc_text']
        table = rec['loc_table']
      end
    
      lonlat = get_center(table,gids[0])
      lon = lonlat[0]
      lat = lonlat[1]  
    
      create_hili_map(table,gids)
    
      return_data = Hash.new
      return_data[:success] = true
      return_data[:totalcount] = 1
      return_data[:records] = [{
        :loc_gid => gid,
        :loc_text => text,
        :loc_table => table,
        :lon => lon, 
        :lat => lat
      }]
    else # found == 0
      return_data = Hash.new
      return_data[:success] = true
      return_data[:totalcount] = 0
      return_data[:records] = [{}]
    end
    con.close
    return_data
  end

  def log_getPolygonWKT(msg)
    log = open("/tmp/getPolygonWKT","a")
    log.write(msg)
    log.write("\n")
    log.close
  end

  def gen_kml(fn, s, h)
    kmlpath = "../#{fn}"

    k = open(kmlpath,"w")
    kml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    kml += "<kml xmlns=\"http://earth.google.com/kml/2.1\">"
    kml += "  <Folder>"
    kml += "    <name>kml</name>"
    kml += "    <Style id=\"gg-pin-green\">"
    kml += "      <IconStyle>"
    kml += "        <Icon>"
    kml += "          <href>img/gg-pin-green.png</href>"
    kml += "        </Icon>"
    kml += "      </IconStyle>"
    kml += "    </Style>"
    kml += "    <Style id=\"gg-pin-pink\">"
    kml += "      <IconStyle>"
    kml += "        <Icon>"
    kml += "          <href>img/gg-pin-pink.png</href>"
    kml += "        </Icon>"
    kml += "      </IconStyle>"
    kml += "    </Style>"
    kml += "    <Style id=\"gg-pin-blue\">"
    kml += "      <IconStyle>"
    kml += "        <Icon>"
    kml += "          <href>img/gg-pin-blue.png</href>"
    kml += "        </Icon>"
    kml += "      </IconStyle>"
    kml += "    </Style>"
    kml += "    <Placemark>"
    
    geom = lon = lat = nil
    colx = nil
    (2..10).each do |n|
      h.each do |hdr,col|
        colx = col
        if (hdr.downcase == 'x' or hdr.downcase == 'lon' or hdr.downcase == 'lng')
          lon = s.cell(col,n)
          next
        elsif (hdr.downcase == 'y' or hdr.downcase == 'lat')
          lat = s.cell(col,n)
          next
        end
        if (!lon.nil? and !lat.nil?)
          geom = "<coordinates>#{lon},#{lat}</coordinates>"
        end
        if (hdr.downcase == 'icon')
          kml += "      <styleUrl>##{s.cell(col,n)}</styleUrl>\n"
        else
          kml += "      <#{hdr}>#{s.cell(col,n)}</#{hdr}>\n"
        end
      end
      kml += "      <Point>\n"
      kml += "        #{geom}\n"
      kml += "      </Point>\n"
      kml += "    </Placemark>\n"
      break if s.cell(colx,n+1).to_s.strip.length == 0
      kml += "    <Placemark>\n"
      geom = lon = lat = nil
    end
    kml += "  </Folder>\n"
    kml += "</kml>\n"

    k.write(kml)
    k.close
  end

  def create_kml(xls)
    s = Roo::Spreadsheet.open(xls)
    s.default_sheet = s.sheets.first

    # Check header
    h = {}
    max = 0
    ('A'..'Z').each do |c|
      hdr = s.cell(c,1)
        if hdr.nil?
        break
      end
      h[hdr] = c
    end

    orig_name = xls.split('/').last.split('.').first
    kmlname = "kml/#{orig_name}.kml"
    gen_kml(kmlname, s, h)
    kmlname
  end

  def log_check_forest_info(msg)
    log = open("/tmp/dsimapcloud.log","a")
    log.write(msg)
    log.write("\n")
    log.close
  end

  def check_rforest_info(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select name_th,mapsheet,area_decla,dec_date,ratchakija,ton "
    sql += "from reserve_forest "
    sql += "where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    log_check_forest_info("check_rforest-sql: #{sql}")
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    msg = "NA"
    if (found == 1)
      res.each do |rec|
        name = rec['name_th']
        mapsheet = rec['mapsheet']
        area_decla = rec['area_decla']
        # Add comma to large number
        area_decla = area_decla.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
        dec_date = rec['dec_date']
        ratchakija = rec['ratchakija']
        ton = rec['ton']
        msg = "<font face=\"time, serif\" size=\"4\"><b><i>เขตป่าสงวน#{name}</i></b><br />ระวาง: #{mapsheet}<br/>"
        msg += "เนื้อที่: #{area_decla} ไร่<br />"
        msg += "ประกาศเมื่อ: #{dec_date}<br />"
        msg += "ราชกิจจานุเบกษา เล่ม: #{ratchakija} ตอนที่: #{ton}</font>"
      end
    end
    #log_check_forest_info("check_rforest-msg: #{msg}")
    msg
  end

  def check_m30forest(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select area,rai "
    sql += "from mangrove_2530 "
    sql += "where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    #log_check_forest_info("check_m30forest-sql: #{sql}")
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    msg = "NA"
    if (found == 1)
      res.each do |rec|
        area = sprintf("%.2f", rec['area'].to_f)
        rai = sprintf("%.2f", rec['rai'].to_f)
        msg = "<font face=\"time, serif\" size=\"4\"><b><i>เขตป่าชายเลน 2530</i></b><br />"
        msg += "พื้นที่:#{area} ตร.ม. (#{rai} ไร่)</font>"
      end
    end
    #log_check_forest_info("check_m30forest-msg: #{msg}")
    msg 
  end

  def check_m43forest(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select area,rai "
    sql += "from mangrove_2543 "
    sql += "where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    #log_check_forest_info("check_m43forest-sql: #{sql}")
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    msg = "NA"
    if (found == 1)
      res.each do |rec|
        area = sprintf("%.2f", rec['area'].to_f)
        rai = sprintf("%.2f", rec['rai'].to_f)
        msg = "<font face=\"time, serif\" size=\"4\"><b><i>เขตป่าชายเลน 2543</i></b><br />"
        msg += "พื้นที่:#{area} ตร.ม. (#{rai} ไร่)</font>"
      end
    end
    #log_check_forest_info("check_m43forest-msg: #{msg}")
    msg 
  end

  def check_m52forest(lon,lat)
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "select lu52_nam,amphoe_t,prov_nam_t,sq_km "
    sql += "from mangrove_2552 "
    sql += "where contains(the_geom,"
    sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
    #log_check_forest_info("check_m52forest-sql: #{sql}")
    res = con.exec(sql)
    con.close
    found = res.num_tuples
    msg = "NA"
    if (found == 1)
      res.each do |rec|
        name = rec['lu52_nam']
        amp = rec['amphoe_t']
        prov = rec['prov_nam_t']
        area = sprintf("%.2f", rec['sq_km'].to_f)
        msg = "<font face=\"time, serif\" size=\"4\"><b><i>เขต#{name} 2552</i></b><br />"
        msg += "#{amp} #{prov}<br />"
        msg += "พื้นที่:#{area} ตร.ม.</font>"
      end
    end
    #log_check_forest_info("check_m52forest-msg: #{msg}")
    msg 
  end


protected

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == "new"
      "login"
    else
      "application"
    end
  end

end
