class AddSlackToWebapplications < ActiveRecord::Migration
  def change
    add_column :web_applications, :slack_channels, :json
  end
end
