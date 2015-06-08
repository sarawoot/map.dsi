class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:staff]
  def index
    @atm = [];
    if params[:code].present?
      authenticate_user!
      res = RestClient.post 'http://172.16.7.15/dsi-i2-ws/map.asmx/GetBankByMachineCode', 
                            {machine_code: params[:code]}, 
                            :content_type => :json, 
                            :accept => :json
      @atm = JSON.parse(res.body)[0]
      if @atm["bank_code"] == '004'
        coordinate = Coordinates.utm_to_lat_long("WGS-84", 
                                  @atm["longitude"], 
                                  @atm["latitude"], 
                                  "47N")
        @atm["longitude"] = coordinate[:long]
        @atm["latitude"] = coordinate[:lat]
      end
    end

  end

  def staff
  end
end
