class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
  end

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_not_found(e)
    respond_to do |f|
      f.html{ render "public/404.html", :status => 404 }
    end
  end

  def current_user
    User.find_by_email(session[:email])
  end

  def require_login
    if current_user.nil?
      redirect_to root_url
    end
  end
end
