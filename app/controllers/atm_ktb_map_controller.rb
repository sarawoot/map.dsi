# -*- encoding : utf-8 -*-
class AtmKtbMapController < ApplicationController
  layout "atm_ktb_map"
  before_action :authenticate_user!
  def index
    @atm_ktb = [];
    if params[:code].present?
      @atm_ktb = AtmKtb.select("location, longitude, latitude")
                       .where(machinecod: params[:code])
                       .first
    end
    if @atm_ktb.blank?
      render text: "กรุณาระบุรหัสเครื่อง"
    end
  end
end
