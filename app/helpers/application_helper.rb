module ApplicationHelper
  def user_name_or_email(user)
    user.name.present? ? user.name : user.email
  end
end