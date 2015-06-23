module ApplicationHelper
  def current_user
    @user ||= User.last
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
end
