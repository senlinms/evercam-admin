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
    if params[:def].present?
      condition1 = "where (required_licence - valid_licence) > #{params[:def]}"
    else
      condition1 = ""
    end
    condition = "lower(u.username) like lower('%#{params[:queryValue]}%') OR 
                 lower(u.email) like lower('%#{params[:queryValue]}%') OR 
                 lower(u.firstname || ' ' || u.lastname) like lower('%#{params[:queryValue]}%')"
    users = EvercamUser.connection.select_all("select *, (required_licence - valid_licence) def from (
                 select *, (select count(cr.id) from cloud_recordings cr left join cameras c on c.owner_id=u.id where c.id=cr.camera_id and cr.status <>'off') required_licence,
                 (select SUM(l.total_cameras) from licences l left join users uu on l.user_id=uu.id where uu.id=u.id and cancel_licence=false) valid_licence
                 from users u where #{condition} order by u.id desc
                ) t #{condition1}")
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
        users[index]["username"],
        users[index]["firstname"] + " " + users[index]["lastname"],
        users[index]["email"],
        users[index]["api_id"],
        users[index]["api_key"],
        Camera.where(owner_id: users[index]["id"]).count,
        Country.exists?(users[index]["country_id"]) ? Country.find(users[index]["country_id"]).name : "",
        users[index]["created_at"] ? Date.parse(users[index]["created_at"]).strftime("%d/%m/%y %I:%M %p") : "",
        users[index]["confirmed_at"] ? Date.parse(users[index]["confirmed_at"]).strftime("%d/%m/%y %I:%M %p") : "",
        users[index]["last_login_at"] ? Date.parse(users[index]["last_login_at"]).strftime("%d/%m/%y %I:%M %p") : "",
        users[index]["required_licence"],
        users[index]["valid_licence"],
        users[index]["def"],
        users[index]["id"]
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
    params.require(:user).permit(:firstname, :lastname, :email, :country_id, :is_admin)
  end

  def set_user
    @user ||= EvercamUser.find(params[:id])
  end
end
