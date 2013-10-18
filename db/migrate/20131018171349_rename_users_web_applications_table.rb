class RenameUsersWebApplicationsTable < ActiveRecord::Migration
  def change
    rename_table :users_web_applications, :user_web_applications
  end
end
