module WebApplicationsHelper
  def owners(web_app, current_user)
    owners_string = web_app.users.map(&:email).join(",")
    owners_string.empty? ? "none" : owners_string
  end
end
