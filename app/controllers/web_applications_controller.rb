class WebApplicationsController < ApplicationController
  before_action :require_login
  before_action :check_user
  skip_before_action :check_user, except: [:create, :update]

  def show
    begin
      @web_application = WebApplication.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise_not_found
    end
    @web_app_available = @web_application.get_status == "ok" ? true : false
  end

  def index
    user_id = params[:user_id]
    if user_id.present?
      @web_applications = WebApplication.where('user_id = ?', user_id).all
    else
      @web_applications = WebApplication.all
    end
  end

  def new
    @current_user = current_user
    @web_application = WebApplication.new
  end

  def create
    @web_application = current_user.web_applications.build(web_application_params)
    if @web_application.save
      redirect_to user_web_applications_path(current_user)
    else
      flash.now.alert = "The web application cannot not be added. One or more values entered are invalid."
      render :new
    end
  end

  def edit
    @current_user = current_user
    @web_application = @current_user.web_applications.friendly.find(params[:id])
  end

  def update
    @web_application = current_user.web_applications.friendly.find(params[:id])
    if @web_application.update_attributes(web_application_params)
      redirect_to user_web_applications_path(current_user)
    else
      flash.now.alert = "The web application cannot not be updated. One or more values entered are invalid."
      render :edit
    end
  end

  private

  def web_application_params
    params.require(:web_application).permit(:name, :status_url)
  end

  def check_user
    raise User::NotAuthorized if current_user != User.find(params["user_id"])
  end
end
