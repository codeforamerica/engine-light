class User < ActiveRecord::Base
  class NotAuthorized < StandardError; end

  validates_presence_of :email
  has_and_belongs_to_many :web_applications, autosave: true
end
