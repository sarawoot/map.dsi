# -*- encoding : utf-8 -*-
class AtmKtbMapController < ApplicationController
  layout "atm_ktb_map"
  before_action :authenticate_user!
  def index
    @atm_ktb = [];
    if params[:code].present?
      res = RestClient.post 'http://172.16.7.15/dsi-i2-ws/map.asmx/GetBankByMachineCode', 
                            {machine_code: params[:code]}, 
                            :content_type => :json, 
                            :accept => :json
      @atm_ktb = JSON.parse(res.body)[0]
      if @atm_ktb["bank_code"] == '004'
        coordinate = Coordinates.utm_to_lat_long("WGS-84", 
                                  @atm_ktb["longitude"], 
                                  @atm_ktb["latitude"], 
                                  "47N")
        @atm_ktb["longitude"] = coordinate[:long]
        @atm_ktb["latitude"] = coordinate[:lat]
      end
    end
    if @atm_ktb.blank?
      render text: "กรุณาระบุรหัสเครื่อง"
    end
  end
end
