class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId

  validates_uniqueness_of :name
  friendly_id :name, use: :slugged

  def get_status
    status = get(status_url)
    status.try(:[], "status")
  end
end
