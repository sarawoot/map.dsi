# -*- encoding : utf-8 -*-
class DsiRespondController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def process_input
    name = params[:name]
    layer = params[:icon].split('_').last
    layer = layer.gsub(/icon/,'')
    kmlname = "layer_#{layer}"
    descr = params[:description]
    imgname = params[:imgname]
    loc = params[:location]
    insert_kml(kmlname,name,descr,imgname,loc)
    data = {}
    data['success'] = true
    render text: data.to_json
  end

  def file_upload    
    imgname = 'NA'
    if params.has_key?"file"
      file = params["file"].first
      type = file.original_filename.split('.').last
      id = rand(100000000)
      imgname = "#{id}.#{type.downcase}"
      while check_dup(imgname)
        id = rand(100000000)
        imgname = "#{id}.#{type.downcase}"  
      end
      server_file = '../photos/' + "#{id}.#{type}"
      File.open(server_file.untaint, "w") do |f|
        f << file.read
      end
    end

    data = {}
    data['success'] = true
    data['imgname'] = imgname
    data['origname'] = file.original_filename

    render text: data.to_json
  end

  def kml_delete
    id = params[:id]
    con = PGconn.connect("localhost",5432,nil,nil,"dsi","admin")
    sql = "DELETE FROM kml "
    sql += "WHERE id=#{id} "
    con.exec(sql)
    con.close

    # Restart SEQUENCE to 1 if 0 record found in kml
    check_records()

    data = {}
    data['success'] = true

    render text: data.to_json
  end

  def checkLonLat2
    lodd = params[:lodd]
    lomm = params[:lomm]
    loss = params[:loss]
    ladd = params[:ladd]
    lamm = params[:lamm]
    lass = params[:lass]

    lon = dms2dd(lodd,lomm,loss)
    lat = dms2dd(ladd,lamm,lass)

    npark = check_npark(lon,lat)
    rforest = check_rforest(lon,lat)

    msg = "พิกัด #{ladd}&deg; #{lamm}&apos; #{lass}&quot; N "
    msg += "#{lodd}&deg; #{lomm}&apos; #{loss}&quot; E<br>"

    if (npark == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตอุทยานแห่งชาติ</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตอุทยานแห่งชาติ#{npark}</font></b>"
    end

    if (rforest == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตป่าสงวน</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตป่าสงวน#{rforest}</font></b>"
    end

    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"
    render text: data
  end

  def checkLonLatDD
    lon = params[:lon]
    lat = params[:lat]

    npark = check_npark(lon,lat)
    rforest = check_rforest(lon,lat)

    msg = ""

    if (npark == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตอุทยานแห่งชาติ</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตอุทยานแห่งชาติ#{npark}</font></b>"
    end

    if (rforest == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตป่าสงวน</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตป่าสงวน#{rforest}</font></b>"
    end

    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"

    render text: data    
  end

  def checkLonLatWKT
    wkt = params[:wkt]

    npark = check_npark_wkt(wkt)
    rforest = check_rforest_wkt(wkt)

    msg = ""

    if (npark == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตอุทยานแห่งชาติ</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตอุทยานแห่งชาติ#{npark}</font></b>"
    end

    if (rforest == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตป่าสงวน</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตป่าสงวน#{rforest}</font></b>"
    end

    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"

    render text: data    
  end

  def checkUTM
    utmn = params[:utmn]
    utme = params[:utme]
    zone = params[:zone]
    lonlat = convert_gcs(utmn, utme, zone)
    lon = lonlat.first
    lat = lonlat.last
    npark = check_npark(lon,lat)
    rforest = check_rforest(lon,lat)
    msg = "พิกัด #{utmn}:N "
    msg += "#{utme}:E<br>"
    msg += "Zone #{zone} (WGS84)<br>"
    if (npark == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตอุทยานแห่งชาติ</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตอุทยานแห่งชาติ#{npark}</font></b>"
    end
    if (rforest == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตป่าสงวน</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตป่าสงวน#{rforest}</font></b>"
    end
    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"
    render text: data  
  end

  def checkUTMIndian
    utmn = params[:utmn]
    utme = params[:utme]
    zone = params[:zone]

    lonlat = convert_gcs(utmn, utme, zone)

    lon = lonlat.first
    lat = lonlat.last

    npark = check_npark(lon,lat)
    rforest = check_rforest(lon,lat)

    msg = "พิกัด #{utmn}:N "
    msg += "#{utme}:E<br>"
    msg += "Zone #{zone} (Indian 1975)<br>"

    if (npark == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตอุทยานแห่งชาติ</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตอุทยานแห่งชาติ#{npark}</font></b>"
    end

    if (rforest == "NA")
      msg += "<br><b><font color=\"green\">ไม่อยู่ในเขตป่าสงวน</font></b>"
    else
      msg += "<br><b><font color=\"red\">อยู่ในเขตป่าสงวน#{rforest}</font></b>"
    end

    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"

    render text: data
  end

  def search_googlex
    query = params[:query]
    start = params[:start].to_i
    limit = params[:limit].to_i
    exact = params[:exact].to_s.to_i
    if start == 0
      limit = 5
    end
    data = search_location(query, start, limit, exact)
    render text: data.to_json
  end

  def getPolygonWKT
    table = params[:table]
    gid = params[:gid]

    con = PGconn.connect("localhost",5432,nil,nil,"dsi","postgres")
    sql = "SELECT gid,astext(the_geom) "
    sql += "FROM #{table} "
    sql += "WHERE gid=#{gid} "

    log_getPolygonWKT("sql: #{sql}")

    res = con.exec(sql)
    con.close

    gidx = res[0][0]
    geometry = res[0][1]

    log_getPolygonWKT("gidx: #{gidx}")
    log_getPolygonWKT("geometry: #{geometry}")

    render text: geometry
  end

  def file_upload_xls
    ENV['ROO_TMP'] = "/var/www/tmp"
    kmlname = 'NA'

    if params[:file].present?
      file = params[:file].first 
      type = file.original_filename.split('.').last
      
      server_file = '../xls/' + file.original_filename
      if File.exists?(server_file)
        File.delete(server_file)
      end
      File.open(server_file.untaint, "w") do |f|
        f << file.read
      end
      kmlname = create_kml(server_file)
    end

    data = {}
    data['success'] = true
    data['kmlname'] = kmlname

    render text: data.to_json
  end

  def check_forest_info
    layer = params[:layer]
    lon = params[:lon].to_f
    lat = params[:lat].to_f

    msg = nil

    if layer == 'national_park'
      msg = check_npark(lon,lat)
    elsif layer == 'reserve_forest'
      msg = check_rforest_info(lon,lat)
    elsif layer == 'mangrove_2530'
      msg = check_m30forest(lon,lat)
    elsif layer == 'mangrove_2543'
      msg = check_m43forest(lon,lat)
    elsif layer == 'mangrove_2552'
      msg = check_m52forest(lon,lat)
    end

    data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"

    render text: data
  end

  def get_lonlat_from_ip
    GeoIp.api_key = 'c17f7c8328438300c26954b002775b8b79b17636647426c1d5115af423c51d71'
    GeoIp.timeout = 10

    ip = request.remote_ip
    h = GeoIp.geolocation(ip)
    lon = h[:longitude]
    lat = h[:latitude]
    data = "{success:true, 'lon':#{lon}, 'lat':#{lat}}"
    render text: data
  end

  def atm_ktb
    # query = params[:query]
    # start = params[:start].to_i
    # limit = params[:limit].to_i
    # search = ""
    # search = " short_name like '%#{query}%' " if query.present?
    # sql = AtmKtb.where(search)
    # datas = {}
    # datas[:success] = true
    # datas[:records] = sql.select("gid, short_name, st_x(geom) as x, st_y(geom) as y ")
    #   .limit(limit)
    #   .offset(start)
    #   .map{|u| {
    #     short_name: u.short_name,
    #     x: u.x,
    #     y: u.y,
    #     id: u.gid
    #   } }
    # datas[:totalcount] = sql.count
    # render text: datas.to_json

    res = RestClient.post 'http://172.16.7.15/dsi-i2-ws/map.asmx/GetAtmMapCombobox', 
                          {
                            bank_code: params[:bank_code],
                            query: params[:query],
                            page: params[:page],
                            start: params[:start],
                            limit: params[:limit]
                          }, 
                          :content_type => :json, :accept => :json
    # body = JSON.parse(res.body)
    render text: res.body

  end

  def google_direction
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=#{params[:start]}&destination=#{params[:end]}&alternatives=true"
    res = RestClient.get(url)
    render text: res.body
  end
end
