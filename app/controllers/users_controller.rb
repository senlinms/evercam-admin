class UsersController < ApplicationController
  before_action :authorize_admin
  before_action :set_user, only: [:show, :update]
  require "intercom"

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
    col_for_order = params[:order]["0"]["column"]
    order_for = params[:order]["0"]["dir"]
    case_value = "(CASE WHEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) >= 0 THEN (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) ELSE 0 end)"

    sorting1 = "order by u.id #{order_for}"
    sorting2 = ""
    first_sort = ["0", "1", "2", "3", "4", "5", "6", "8", "9", "10", "11", "12", "13", "15"]
    second_sort = ["7", "14"]
    if first_sort.include? col_for_order
      sorting1 = sorting(col_for_order, order_for)
    end
    if second_sort.include? col_for_order
      sorting2 = sorting(col_for_order, order_for)
    end

    if params[:username].present? && params[:email].present? && params[:fullname].present?
      condition = "where lower(u.username) like lower('%#{params[:username]}%') and lower(u.firstname || ' ' || u.lastname) like lower('%#{params[:fullname]}%') and lower(u.email) like lower('%#{params[:email]}%')"
    elsif params[:username].present? && params[:email].present?
      condition = "where lower(u.username) like lower('%#{params[:username]}%') and lower(u.email) like lower('%#{params[:email]}%')"
    elsif params[:email].present? && params[:fullname].present?
      condition = "where lower(u.firstname || ' ' || u.lastname) like lower('%#{params[:fullname]}%') and lower(u.email) like lower('%#{params[:email]}%')"
    elsif params[:username].present? && params[:fullname].present?
      condition = "where lower(u.firstname || ' ' || u.lastname) like lower('%#{params[:fullname]}%') and lower(u.username) like lower('%#{params[:username]}%')"
    elsif params[:username].present?
      condition = "where lower(u.username) like lower('%#{params[:username]}%')"
    elsif params[:email].present?
      condition = "where lower(u.email) like lower('%#{params[:email]}%')"
    elsif params[:fullname].present?
      condition = "where lower(u.firstname || ' ' || u.lastname) like lower('%#{params[:fullname]}%')"
    else
      condition = ""
    end

    if params[:total_cameras].present?
      condition2 = "where (cameras_owned + camera_shares) = #{params[:total_cameras]}"
    elsif params[:licREQ1].present? && params[:licREQ2].present?
      condition2 = "where required_licence > #{params[:licREQ1]} and required_licence < #{params[:licREQ2]}"
    elsif params[:licVALID1].present? && params[:licVALID2].present?
      condition2 = "where valid_licence > #{params[:licVALID1]} and valid_licence < #{params[:licVALID2]}"
    elsif params[:licDEF1].present? && params[:licDEF2].present?
      condition2 = "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) > #{params[:licDEF1]} and (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) < #{params[:licDEF2]}"
    elsif params[:licDEF1].present?
      condition2 = "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) > #{params[:licDEF1]}"
    elsif params[:licDEF2].present?
      condition2 = "where (required_licence - (CASE WHEN valid_licence >=0 THEN valid_licence ELSE 0 END)) < #{params[:licDEF2]}"
    elsif params[:licVALID1].present?
      condition2 = "where valid_licence > #{params[:licVALID1]}"
    elsif params[:licVALID2].present?
      condition2 = "where valid_licence < #{params[:licVALID2]}"
    elsif params[:licREQ1].present?
      condition2 = "where required_licence > #{params[:licREQ1]}"
    elsif params[:licREQ2].present?
      condition2 = "where required_licence < #{params[:licREQ2]}"
    else
      condition2 = ""
    end
    users = EvercamUser.connection.select_all("select *, #{case_value} def, (cameras_owned + camera_shares) total_cameras from (
                 select *, (select count(cr.id) from cloud_recordings cr left join cameras c on c.owner_id=u.id where c.id=cr.camera_id and cr.status <>'off' and cr.storage_duration <> 1) required_licence,
                 (select SUM(l.total_cameras) from licences l left join users uu on l.user_id=uu.id where uu.id=u.id and cancel_licence=false) valid_licence,
                 (select count(*) from cameras cc left join users uuu on cc.owner_id=uuu.id where uuu.id=u.id) cameras_owned,
                 (select count(*) from camera_shares cs left join users uuuu on cs.user_id=uuuu.id where uuuu.id = u.id) camera_shares,
                 (select name from countries ct left join users uuuuu on ct.id=uuuuu.country_id where uuuuu.id=u.id) country
                 from users u #{condition} #{sorting1}
                ) t #{condition2} #{sorting2}")
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
        users[index]["cameras_owned"],
        users[index]["camera_shares"],
        users[index]["total_cameras"],
        users[index]["country"],
        users[index]["created_at"] ? DateTime.parse(users[index]["created_at"]).strftime("%A, %d %b %Y %l:%M %p") : "",
        users[index]["confirmed_at"] ? DateTime.parse(users[index]["confirmed_at"]).strftime("%A, %d %b %Y %l:%M %p") : "",
        users[index]["last_login_at"] ? DateTime.parse(users[index]["last_login_at"]).strftime("%A, %d %b %Y %l:%M %p") : "",
        users[index]["required_licence"],
        users[index]["valid_licence"],
        users[index]["def"],
        users[index]["payment_method"],
        users[index]["id"],
        check_env
      ]
    end
    @pageload = false
    render json: records
  end

  def get_intercom
    intercom = connect_intercom
    begin
      user = intercom.users.find(:user_id => params["username"])
    rescue

    end
    render json: user
  end

  private

  def add_user_credential(user)
    user.api_id  = SecureRandom.hex(4)
    user.api_key = SecureRandom.hex
    user.save
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :country_id, :payment_method, :insight_id, :insight_auth_key)
  end

  def set_user
    @user ||= EvercamUser.find(params[:id])
  end

  def sorting(col, order)
    case col
    when "0"
      "order by u.username #{order}"
    when "1"
      "order by u.firstname #{order}"
    when "2"
      "order by u.email #{order}"
    when "3"
      "order by u.api_id #{order}"
    when "4"
      "order by u.api_key #{order}"
    when "5"
      "order by cameras_owned #{order}"
    when "6"
      "order by camera_shares #{order}"
    when "7"
      "order by total_cameras #{order}"
    when "8"
      "order by country #{order}"
    when "9"
      "order by created_at #{order}"
    when "12"
      "order by required_licence #{order}"
    when "11"
      "order by last_login_at #{order}"
    when "13"
      "order by valid_licence #{order}"
    when "14"
      "order by def #{order}"
    when "15"
      "order by payment_method #{order}"
    when "10"
      "order by u.id desc"
    else
      "order by id #{order}"
    end
  end
end
