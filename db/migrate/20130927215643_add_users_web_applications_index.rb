class AddUsersWebApplicationsIndex < ActiveRecord::Migration
  def change
    add_index(:users_web_applications, [:user_id, :web_application_id], :unique => true)
  end
end
