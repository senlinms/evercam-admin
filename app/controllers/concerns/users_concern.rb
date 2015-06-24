
module UsersConcern
  def set_user
    @user = User.find(paramsuser_id).decorate
  end

  def set_users
    @users = policy_scope(User.where(tld_id: nil))
    @users = @users.decorate
    @users = @users.paginated(self)
  end
end
