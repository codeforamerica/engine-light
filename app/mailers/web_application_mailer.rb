class WebApplicationMailer < ActionMailer::Base
  default from: "alerts@codeforamerica.org"

  def outage_notification(web_application)
    user_emails = web_application.users.map(&:email)
    @web_application = web_application
    mail(to: user_emails, subject: "#{web_application.name} is down")
  end

  def recovery_notification(web_application)
    user_emails = web_application.users.map(&:email)
    @web_application = web_application
    mail(to: user_emails, subject: "#{web_application.name} has recovered")
  end
end
