class UsersController < ApplicationController
  before_action :require_login
  before_action :check_user

  def show
    @current_user = current_user
    @user = User.find(params[:id])
  end

  def edit
    @current_user = current_user
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = "Your settings were updated"
      redirect_to web_applications_path
    else
      flash.now[:alert] = "Settings could not be saved"
      render :edit
    end
  end

private

  def check_user
    begin
      user = User.find(params[:id])
      if current_user != user && !current_user.is_admin?
        redirect_to root_url
      end
    rescue ActiveRecord::RecordNotFound
      raise_not_found
    end
  end

  def user_params
    params.require(:user).permit(:name)
  end
end