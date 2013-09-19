class WebApplication < ActiveRecord::Base
  include Requester

  validates_uniqueness_of :name

  def to_param
    name
  end

  def get_status
    get(status_url)
  end
end
