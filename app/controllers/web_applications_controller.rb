class WebApplicationsController < ApplicationController
  def show
    begin
      @web_application = WebApplication.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise_not_found
    end
    @web_app_available = @web_application.get_status == "ok" ? true : false
  end

  def index
    @web_applications = WebApplication.all
  end
end
