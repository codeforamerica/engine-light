class WebApplicationsController < ApplicationController
  def show
    @web_app = WebApplication.friendly.find(params[:id]) || raise_not_found
    @web_app_available = @web_app.get_status == "ok" ? true : false
  end
end
