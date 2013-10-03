module WebApplicationsHelper
  def owners(web_app, current_user)
    owners_string = web_app.users.map(&:local_email_part).join(",")
    owners_string.empty? ? "none" : owners_string
  end
end
