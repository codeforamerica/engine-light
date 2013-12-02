class StaticController < ApplicationController
  def about
    if current_user.present?
      @current_user = current_user
    end
  end
end
