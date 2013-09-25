class User < ActiveRecord::Base
  class NotAuthorized < StandardError; end

  validates_presence_of :email
  has_many :web_applications
end
