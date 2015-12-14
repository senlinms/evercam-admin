class PasswordsController < Devise::PasswordsController

	protected

  def after_sending_reset_password_instructions_path_for(*)
    new_user_password_path
  end
end
