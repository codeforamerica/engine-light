class UserWebApplication < ActiveRecord::Base
  belongs_to :user
  belongs_to :web_application
end