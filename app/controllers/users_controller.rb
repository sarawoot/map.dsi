class UsersController < ApplicationController
  layout "user"
  before_action :authenticate_user!
  respond_to :html, :xml, :json
  before_action :set_user, only: [:edit, :update]
  before_action :get_role

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(users_path) }
        format.xml { render xml: @user }
      else
        format.html { render action: "new" }
        format.xml { render xml: @user }
      end
    end
  end

  def edit
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end
    respond_to do |format|
      if @user.update(user_params)
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(users_path) }
        format.xml { render xml: @user }
      else
        format.html { render action: "edit" }
        format.xml { render xml: @user }
      end
    end
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :fname, :lname)
    end

    def get_role
      if current_user.admin != '1'
        redirect_to root_path
        return
      end
    end
end
