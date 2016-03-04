class UsersController < ApplicationController
  before_action :authorize_admin
  before_action :set_user, only: [:show, :update]

  def index
    if params[:q]
      @user = EvercamUser.find_by_email(params[:q]).decorate
      @countries = Country.all
      render "show", params: { user: @user, countries: @countries }
    else
      @users = EvercamUser.all.includes(:country, :cameras).limit(50).order("created_at desc").decorate
      if params[:true]
        @lateusers = EvercamUser.where("id < ?", @users.first.id).includes(:country, :cameras).order("created_at desc").decorate
        records = []
        @lateusers.each do |user|
          records[records.length] = [
            user.username,
            user.fullname,
            user.email,
            user.api_id,
            user.api_key,
            user.cameras.length,
            user.country_name,
            user.registered_at,
            user.confirmed_email,
            user.last_login
          ]
        end
      end
      respond_to do |format|
        format.html { render "index" }
        format.json { render json: records }
      end
    end
  end

  def show
    @countries = Country.all
    if @user.api_id.blank? && @user.api_key.blank?
      add_user_credential(@user)
    end
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

  private

  def add_user_credential(user)
    user.api_id  = SecureRandom.hex(4)
    user.api_key = SecureRandom.hex
    user.save
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :country_id, :is_admin)
  end

  def set_user
    @user ||= EvercamUser.find(params[:id])
  end
end
