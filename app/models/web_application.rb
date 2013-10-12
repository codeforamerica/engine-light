class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId

  validates_presence_of :name, :status_url
  validates_uniqueness_of :name
  validate :status_url_is_valid?
  after_save :get_current_status
  has_and_belongs_to_many :users, autosave: true
  friendly_id :name, use: :slugged
  attr_accessor :status_checked_at, :resources, :dependencies


  def get_current_status
    begin
      response = get(status_url)
    rescue
      self.current_status = "down"
      return
    end
    self.current_status = response.try(:[], "status")

    @status_checked_at = Time.at(response.try(:[], "updated").to_i).utc
    @resources = response.try(:[], "resources")
    @dependencies = response.try(:[], "dependencies")
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
