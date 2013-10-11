class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId

  validates_presence_of :name, :status_url
  validates_uniqueness_of :name
  validate :status_url_is_valid?
  has_and_belongs_to_many :users, autosave: true
  friendly_id :name, use: :slugged

  def update_current_status!
    begin
      status = get(status_url)
    rescue
      update_attributes(current_status: "down")
      return
    end
    status_string = status.try(:[], "status")
    update_attributes(current_status: status_string)
  end

  def root_url
    uri = URI.parse(status_url)
    "#{uri.scheme}://#{uri.host}"
  end

private

  def status_url_is_valid?
    begin
      get(status_url)
    rescue
      errors.add(:status_url, "is unavailable or does not return a valid response")
    end
  end
end
