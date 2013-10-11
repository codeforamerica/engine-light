class AddCurrentStatusToWebApplications < ActiveRecord::Migration
  def change
    add_column :web_applications, :current_status, :string
  end
end
