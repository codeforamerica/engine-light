class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId

  validates_presence_of :name, :status_url
  validates_uniqueness_of :name
  has_and_belongs_to_many :users, autosave: true
  friendly_id :name, use: :slugged

  def get_status
    status = get(status_url)
    status.try(:[], "status")
  end
end
