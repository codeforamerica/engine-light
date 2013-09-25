class AddUserToWebApplications < ActiveRecord::Migration
  def change
    add_column :web_applications, :user_id, :integer, null: false
  end
end
