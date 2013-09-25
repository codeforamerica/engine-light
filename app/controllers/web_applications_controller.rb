class WebApplicationsController < ApplicationController
  before_action :require_login

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
end
