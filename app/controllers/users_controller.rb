class UsersController < ApplicationController
  before_action :authorize_admin
  before_action :set_user, only: [:show, :update, :impersonate]

  def index
    @users = User.all.includes(:country, :cameras).decorate
  end

  def show
    @countries = Country.all
    @user = @user.decorate
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'User details updated successfully'
    else
      redirect_to user_path(@user)
    end
  rescue => error
    env["airbrake.error_id"] = notify_airbrake(error)
    Rails.logger.error "Exception caught updating User details.\nCause: #{error}\n" +
                           error.backtrace.join("\n")
    flash[:message] = "An error occurred updating User details. "\
                          "Please try again and, if this problem persists, contact support."
  end

  def impersonate
    if @user
      sign_out
      sign_in @user
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :country_id, :is_admin)
  end

  def set_user
    @user ||= User.find(params[:id])
  end
end
