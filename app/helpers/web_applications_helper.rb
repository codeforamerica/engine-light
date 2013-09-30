module WebApplicationsHelper
  def additional_managers(web_app, current_user)
    managers = web_app.users - [current_user]
    managers_string = managers.map(&:local_email_part).join(",")
    managers_string.empty? ? "none" : managers_string
  end
end
