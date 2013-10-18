class User < ActiveRecord::Base
  class NotAuthorized < StandardError; end

  validates_presence_of :email
  has_many :web_applications, through: :user_web_applications, autosave: true
  has_many :user_web_applications

  def is_admin?
    role == "admin"
  end
end
