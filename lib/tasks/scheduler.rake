desc "Checks application statuses via heroku scheduler"
task :check_app_statuses => :environment do
  WebApplication.all.each do |web_app|
    if web_app.get_status != "ok"
      if send_downtime_notification?(web_app)
        WebApplicationMailer.outage_notification(web_app).deliver
        web_app.update_attributes(last_downtime_notification_at: Time.now)
      end
    end
    if web_app.get_status == "ok"
      if send_recovery_notification?(web_app)
        WebApplicationMailer.recovery_notification(web_app).deliver
        web_app.update_attributes(last_downtime_notification_at: nil)
      end
    end
  end
end

def send_downtime_notification?(web_app)
  web_app.last_downtime_notification_at.nil? ||
  (Time.now - web_app.last_downtime_notification_at) >= 1.hour
end

def send_recovery_notification?(web_app)
  web_app.last_downtime_notification_at.present?
end