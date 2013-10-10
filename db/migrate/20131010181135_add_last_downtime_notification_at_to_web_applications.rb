class AddLastDowntimeNotificationAtToWebApplications < ActiveRecord::Migration
  def change
    add_column :web_applications, :last_downtime_notification_at, :datetime
  end
end
