class User < ActiveRecord::Base
  class NotAuthorized < StandardError; end

  validates_presence_of :email
  has_and_belongs_to_many :web_applications, autosave: true

  def local_email_part
    email.split(/@(cfa|codeforamerica)\.org$/).first
  end
end
