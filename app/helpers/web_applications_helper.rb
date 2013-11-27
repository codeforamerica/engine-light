module WebApplicationsHelper
  def owners(web_app, current_user)
    owners_html =
    web_app.users.map do |user|
      '<a>' + user_name_or_email(user) + '</a>'
    end
    owners_html.join(", ").html_safe
  end

  def user_name_or_email(user)
    user.name.present? ? user.name : user.email
  end

  def resource_list(resource_hash)
    resource_array = []
    if resource_hash.present?
      resource_hash.each_pair do |key, value|
        resource_array << "#{key}: #{value}"
      end
    end
    resource_array
  end

  def get_error_string(web_application, attribute)
    errors = web_application.errors[attribute].try(:join, ", ")
    errors.present? ? "- #{errors}": ""
  end
end
