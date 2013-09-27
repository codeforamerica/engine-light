class WebApplicationsController < ApplicationController
  before_action :require_login

  def show
    begin
      @web_application = current_user.web_applications.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise_not_found
    end
    @web_app_available = @web_application.get_status == "ok" ? true : false
  end

  def index
    @current_user = current_user
    @web_applications = @current_user.web_applications
  end

  def new
    @current_user = current_user
    @web_application = WebApplication.new
  end

  def create
    @current_user = current_user
    @web_application = @current_user.web_applications.build(web_application_params)
    if @current_user.save
      redirect_to web_applications_path
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
      redirect_to web_applications_path
    else
      flash.now.alert = "The web application cannot not be updated. One or more values entered are invalid."
      render :edit
    end
  end

  private

  def web_application_params
    params.require(:web_application).permit(:name, :status_url)
  end
end
