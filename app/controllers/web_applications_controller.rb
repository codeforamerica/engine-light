class WebApplicationsController < ApplicationController
  def show
    @web_app = WebApplication.find_by_name(params[:id]) || raise_not_found
  end
end
