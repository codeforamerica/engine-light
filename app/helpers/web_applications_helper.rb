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

  def owners_list(owners)
    owners_html =
    owners.map do |user|
      '<li><a>' + user_name_or_email(user) + '</a></li>'
    end
    "<ul>#{owners_html.join}</ul>".html_safe
  end

  def resource_list(resource_hash)
    return "" unless resource_hash.present?
    resource_array = []
    resource_hash.each_pair do |key, value|
      resource_array << "<dt>#{key}</dt> <dd>#{value}%</dd>"
    end
    "<dl>#{resource_array.join}</dl>".html_safe
  end

  def dependencies_list(dependencies)
    return "" unless dependencies.present?
    dependencies_html =
    dependencies.map do |dependency|
      "<li>#{dependency}</li>"
    end
    "<ul>#{dependencies_html.join}</ul>".html_safe
  end

  def get_error_string(web_application, attribute)
    errors = web_application.errors[attribute].try(:join, ", ")
    errors.present? ? "#{errors}": ""
  end
end
