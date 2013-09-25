class WelcomeController < ApplicationController
  def index
    if current_user.present?
      @current_user = current_user
    end
  end
end
