module WebApplicationsHelper
  def owners(web_app, current_user)
    owners_string = web_app.users.map(&:email).join(" ")
    owners_string.empty? ? "none" : owners_string
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
end
