class WebApplicationsController < ApplicationController
  before_action :require_login
  before_action :check_app_access
  skip_before_action :check_app_access, only: [:new, :index, :create, :update]

  def show
    @current_user = current_user
    @web_application = WebApplication.friendly.find(params[:id])
    @web_application.get_current_status
    @web_application.save
  end

  def index
    @current_user = current_user
    if @current_user.is_admin?
      @web_applications = WebApplication.all
    else
      @web_applications = @current_user.web_applications
    end
  end

  def new
    @current_user = current_user
    @web_application = WebApplication.new
  end

  def create
    @current_user = current_user
    user = params["web_application"].delete("user")
    @web_application = @current_user.web_applications.build(web_application_params)
    user["ids"].each do |id|
      if id.present?
        @web_application.users << User.find(id)
      end
    end

    if @current_user.save
      redirect_to web_applications_path
    else
      flash.now.alert = "The web application cannot not be added. One or more values entered are invalid."
      render :new
    end
  end

  def edit
    @current_user = current_user
    @web_application = WebApplication.friendly.find(params[:id])
  end

  def update
    @web_application = WebApplication.friendly.find(params[:id])
    user = params["web_application"].delete("user")

    web_application_users = [current_user]
    user["ids"].each do |id|
      if id.present?
         web_application_users << User.find(id)
      end
    end
    @web_application.users = web_application_users

    if @web_application.update_attributes(web_application_params)
      redirect_to web_applications_path
    else
      flash.now.alert = "The web application cannot not be updated. One or more values entered are invalid."
      render :edit
    end
  end

  def destroy
    @web_application = current_user.web_applications.friendly.find(params[:id])
    if @web_application.destroy
      redirect_to web_applications_path
    else
      flash.now.alert = "The web application cannot not be deleted."
      render :edit
    end
  end

  private

  def check_app_access
    begin
      web_application = WebApplication.friendly.find(params[:id])
      if !current_user.web_applications.exists?(web_application) && !current_user.is_admin?
        redirect_to root_url
      end
    rescue ActiveRecord::RecordNotFound
      raise_not_found
    end
  end

  def web_application_params
    params.require(:web_application).permit(:name, :status_url)
  end
end
