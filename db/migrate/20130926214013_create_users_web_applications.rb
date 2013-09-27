class CreateUsersWebApplications < ActiveRecord::Migration
  def change
    create_table :users_web_applications do |t|
      t.belongs_to :user
      t.belongs_to :web_application
    end

    remove_column :web_applications, :user_id, :integer
  end
end
