desc "Checks application statuses via heroku scheduler"
task :check_app_statuses => :environment do
  apps_to_check = []
  WebApplication.all.each do |web_app|
    web_app.get_current_status
    web_app.save
    if web_app.current_status != "ok"
      apps_to_check << web_app
    end
    if web_app.current_status == "ok" && send_recovery_notification?(web_app)
      WebApplicationMailer.recovery_notification(web_app).deliver
      web_app.update_attributes(last_downtime_notification_at: nil)
    end
  end
  Kernel.sleep(2.minutes)
  double_check_apps(apps_to_check)
end

def send_downtime_notification?(web_app)
  web_app.last_downtime_notification_at.nil? ||
  (Time.now - web_app.last_downtime_notification_at) >= 1.hour
end

def send_recovery_notification?(web_app)
  web_app.last_downtime_notification_at.present?
end

def double_check_apps(apps_to_check)
  apps_to_check.each do |web_app|
    web_app.get_current_status
    web_app.save
    if web_app.current_status != "ok" && send_downtime_notification?(web_app)
      WebApplicationMailer.outage_notification(web_app).deliver
      web_app.update_attributes(last_downtime_notification_at: Time.now)
    end
  end
end