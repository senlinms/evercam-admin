class UsersController < ApplicationController
  before_action :set_user, except: :index

  def index
    @users = User.all.includes(:country, :cameras).decorate
  end

  def show
    @countries = Country.all
  end

  def update
    begin
      @user.update_attributes(firstname: params['firstname'], lastname: params['lastname'],
                               email: params['email'], country_id: params['country_id'],
                               is_admin: params['is_admin'])

      flash[:message] = "User details updated successfully"
      redirect_to "//users/#{params['id']}"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating User details.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      if(error.message.index("ux_users_email"))
        flash[:message] = "The email address specified is already registered for an Evercam account."
      else
        flash[:message] = "An error occurred updating User details. "\
                          "Please try again and, if this problem persists, contact support."
      end
      redirect_to "/users/#{params['id']}"
    end
  end

  def impersonate
    if user
      sign_out
      sign_in user
      redirect_to root_path
    else
      redirect_to :back
    end
  rescue ActionController::RedirectBackError
    redirect_to admin_path
  end

  private

  def set_user
    @user ||= User.find(params[:id]).decorate
  end
end
