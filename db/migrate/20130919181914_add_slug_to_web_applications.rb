class AddSlugToWebApplications < ActiveRecord::Migration
  def change
    add_column :web_applications, :slug, :string
    add_index :web_applications, :slug
  end
end
