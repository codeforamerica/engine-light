class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId

  validates_presence_of :name, :status_url, :user
  validates_uniqueness_of :name
  belongs_to :user
  friendly_id :name, use: :slugged

  def get_status
    status = get(status_url)
    status.try(:[], "status")
  end
end
