class AtmController < ApplicationController
  def ktb
    res = RestClient.post 'http://172.16.7.15/dsi-i2-ws/map.asmx/GetAtmMap', {bank_code: '006'}, :content_type => :json, :accept => :json
    body = JSON.parse(res.body)
    layer = { 
      type: "FeatureCollection",
      crs: { 
        type: "name", 
        properties: { 
          name: "urn:ogc:def:crs:OGC:1.3:CRS84" 
        } 
      },
      features: body
    }
    render text: layer.to_json
  end

  def kbank
    res = RestClient.post 'http://172.16.7.15/dsi-i2-ws/map.asmx/GetAtmMap', {bank_code: '004'}, :content_type => :json, :accept => :json
    body = JSON.parse(res.body)


    body.each { |u|  
      coordinate = Coordinates.utm_to_lat_long("WGS-84", 
                                  u["geometry"]["coordinates"][0], 
                                  u["geometry"]["coordinates"][1], 
                                  "47N")
      u["geometry"]["coordinates"][0] = coordinate[:long]
      u["geometry"]["coordinates"][1] = coordinate[:lat]
    }



    layer = { 
      type: "FeatureCollection",
      crs: { 
        type: "name", 
        properties: { 
          name: "urn:ogc:def:crs:OGC:1.3:CRS84" 
        } 
      },
      features: body
    }
    render text: layer.to_json
  end
end
