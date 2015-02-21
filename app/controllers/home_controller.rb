class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:staff]
  def index
  end

  def staff
  end
end
