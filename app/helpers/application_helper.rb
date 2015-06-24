module ApplicationHelper
  # TODO: remove this when authentication is ready
  def current_user
    User.where(is_admin: true).first
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
end
