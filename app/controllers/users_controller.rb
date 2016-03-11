class UsersController < ApplicationController
  before_action :authorize_admin
  before_action :set_user, only: [:show, :update]

  def index
    if params[:q]
      @user = EvercamUser.find_by_email(params[:q]).decorate
      @countries = Country.all
      render "show", params: { user: @user, countries: @countries }
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

  def load_users
    condition = "lower(users.username) like lower('%#{params[:username]}%') OR 
      lower(users.email) like lower('%#{params[:email]}%')"
    users = EvercamUser.where(condition).includes(:country, :cameras).order("created_at desc").decorate
    total_records = users.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = { data: [], draw: table_draw, recordsTotal: total_records, recordsFiltered: total_records }

    (display_start..index_end).each do |index|
      records[:data][records[:data].count] = [
        users[index].username,
        users[index].fullname,
        users[index].email,
        users[index].api_id,
        users[index].api_key,
        users[index].cameras.length,
        users[index].country_name,
        users[index].registered_at,
        users[index].confirmed_email,
        users[index].last_login,
        users[index].id
      ]
    end
    render json: records
  end

  private

  def add_user_credential(user)
    user.api_id  = SecureRandom.hex(4)
    user.api_key = SecureRandom.hex
    user.save
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :country_id, :payment_method)
  end

  def set_user
    @user ||= EvercamUser.find(params[:id])
  end
end
