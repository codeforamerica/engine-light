class CreateWebApplications < ActiveRecord::Migration
  def change
    create_table :web_applications do |t|
      t.string :name
      t.timestamps
    end

    add_index :web_applications, :name
  end
end
