class WebApplication < ActiveRecord::Base
  include Requester

  def get_status
    get(status_url)
  end
end
