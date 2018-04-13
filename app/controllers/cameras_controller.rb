class CamerasController < ApplicationController
  before_action :authorize_admin
  require 'evercam'

  def index
  end

  def cleanup
    @api_url = evercam_server
  end

  def cleanup_cameras
    col_for_order = params[:order]["0"]["column"]
    order_for = params[:order]["0"]["dir"]
    last_months_offline = " and (c.is_online = false and c.last_online_at <= '#{Time.now - 12.month}')"

    if params[:camera_exid].present?
      camera_exid = " and lower(c.exid) like lower('%#{params[:camera_exid]}%')"
    end
    if params[:camera_name].present?
      camera_name = " and lower(c.name) like lower('%#{params[:camera_name]}%')"
    end
    if params[:camera_owner].present?
      camera_owner = " and lower(fullname) like lower('%#{params[:camera_owner]}%')"
    end
    if params[:email].present?
      owner_email = " and lower(owner_email) like lower('%#{params[:email]}%')"
    end
    if params[:camera_ip].present?
      camera_ip = " and lower(c.config->>'external_host') like lower('%#{params[:camera_ip]}%')"
    end
    if params[:months].present?
      last_months_offline = " and (c.is_online = false and c.last_online_at <= '#{Time.now - params[:months].to_i.month}')"
    end
    if params[:username].present?
      camera_username = " and lower(c.config->'auth'->'basic'->>'username') like lower('%#{params[:username]}%')"
    end
    if params[:password].present?
      camera_password = " and lower(c.config->'auth'->'basic'->>'password') like lower('%#{params[:password]}%')"
    end

    cameras = Camera.connection.select_all("select * from (
                select c.*,u.firstname || ' ' || u.lastname as fullname, u.email as owner_email, u as user, u.id as user_id, u.api_id, u.api_key,
                v.name as vendor_name, vm.name as vendor_model_name, cr.status as cloud_recording_status,
                cr.frequency as cloud_recording_frequency, cr.storage_duration as cloud_recording_storage_duration,
                (select count(id) as total from camera_shares cs where c.id=cs.camera_id) as total_share from cameras c
                inner JOIN users u on c.owner_id = u.id
                left JOIN vendor_models vm on c.model_id = vm.id
                left JOIN vendors v on vm.vendor_id = v.id
                left JOIN cloud_recordings cr on c.id = cr.camera_id
                ) c where c.owner_id not in (78, 7011, 6120, 116066, 13959, 109148) and (cloud_recording_storage_duration <> -1 or cloud_recording_storage_duration is null)
                #{last_months_offline}#{camera_exid}#{camera_name}#{camera_owner}#{owner_email}#{camera_ip}#{camera_username}#{camera_password}
                #{cleanup_sorting(col_for_order, order_for)}")
    total_records = cameras.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = { data: [], draw: table_draw, recordsTotal: total_records, recordsFiltered: total_records }
    (display_start..index_end).each do |index|
      if cameras[index].present? && cameras[index]["user"].present?
        records[:data][records[:data].count] = [
          cameras[index]["created_at"] ? DateTime.parse(cameras[index]["created_at"]).strftime("%a, %d %b %Y %l:%M %p") : "",
          cameras[index]["last_online_at"] ? DateTime.parse(cameras[index]["created_at"]).strftime("%a, %d %b %Y %l:%M %p") : "",
          cameras[index]["exid"],
          cameras[index]["fullname"],
          cameras[index]["owner_email"],
          cameras[index]["name"],
          cameras[index]["total_share"],
          JSON.parse(cameras[index]["config"]).deep_fetch("external_host") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("external_http_port") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("external_rtsp_port") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("auth", "basic", "username") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("auth", "basic", "password") { "" },
          cameras[index]["is_public"],
          cameras[index]["is_online"],
          cameras[index]["cloud_recording_storage_duration"],
          cameras[index]["cloud_recording_status"],
          cameras[index]["id"],
          cameras[index]["user_id"],
          cameras[index]["api_id"],
          cameras[index]["api_key"],
          check_env
        ]
      end
    end
    render json: records
  end

  def show
    @camera = Camera.find(params[:id]).decorate
  end

  def merge
    if params[:camids]
      delete_camera(params[:camids])
    elsif params[:port] && params[:host] && params[:jpg]
      cameras = filter_camera(params[:port], params[:host], params[:jpg])
      records = []
      cameras.each do |camera|
        records[records.length] = [
          camera["id"],
          camera["exid"],
          camera["name"],
          camera.user ? camera.user["firstname"] : "Deleted",
          camera.user ? camera.user["lastname"] : "User",
          camera.camera_shares.count,
          camera["is_online"],
          camera["created_at"],
          camera["is_public"],
          camera.user ? camera.user["id"] : "",
          camera.user ? camera.user["api_id"] : "",
          camera.user ? camera.user["api_key"] : "",
          check_env,
          camera.cloud_recording || { "status" => "" }["status"]
        ]
      end

      render json: records
    elsif params[:super_cam_id] && params[:super_cam_owner_id] && params[:camera_ids] && params[:owner_ids]
      merge_camera(params[:super_cam_id], params[:super_cam_owner_id], params[:camera_ids], params[:owner_ids])
    else
      @cameras = Camera.run_sql("select count(nullif(c.is_online = false, true)) as online, c.config->>'external_http_port' as
        external_http_port, c.config->>'external_host' as external_host, LOWER(config->'snapshots'->>'jpg')   as jpg, count(*) as
        count, count(nullif(cr.status like 'off','on')) as is_recording from cameras c left join cloud_recordings cr on c.id=cr.camera_id
         group by c.config->>'external_http_port', c.config->>'external_host', LOWER(c.config->'snapshots'->>'jpg') HAVING (
         COUNT(*)>1)")
    end
  end

  def load_cameras
    col_for_order = params[:order]["0"]["column"]
    order_for = params[:order]["0"]["dir"]
    if params[:is_recording].present?
      is_recording = " and lower(is_recording) like lower('%#{params[:is_recording]}%')"
    end
    if params[:camera_exid].present?
      camera_exid = " and lower(c.exid) like lower('%#{params[:camera_exid]}%')"
    end
    if params[:camera_name].present?
      camera_name = " and lower(c.name) like lower('%#{params[:camera_name]}%')"
    end
    if params[:camera_owner].present?
      camera_owner = " and lower(fullname) like lower('%#{params[:camera_owner]}%')"
    end
    if params[:camera_ip].present?
      camera_ip = " and lower(c.config->>'external_host') like lower('%#{params[:camera_ip]}%')"
    end
    if params[:model].present?
      camera_model = " and lower(vendor_model_name) like lower('%#{params[:model]}%')"
    end
    if params[:vendor].present?
      camera_vendor = " and lower(vendor_name) like lower('%#{params[:vendor]}%')"
    end
    if params[:username].present?
      camera_username = " and lower(c.config->'auth'->'basic'->>'username') like lower('%#{params[:username]}%')"
    end
    if params[:password].present?
      camera_password = " and lower(c.config->'auth'->'basic'->>'password') like lower('%#{params[:password]}%')"
    end

    cameras = Camera.connection.select_all("select * from (
                select c.*,u.firstname || ' ' || u.lastname as fullname, u as user, u.id as user_id, u.api_id, u.api_key,
                v.name as vendor_name,vm.name as vendor_model_name, cr.status as is_recording,
                (select count(id) as total from camera_shares cs where c.id=cs.camera_id) as total_share from cameras c
                inner JOIN users u on c.owner_id = u.id
                left JOIN vendor_models vm on c.model_id = vm.id
                left JOIN vendors v on vm.vendor_id = v.id
                left JOIN cloud_recordings cr on c.id = cr.camera_id
                ) c where 1=1
                #{camera_exid}#{is_recording}#{camera_name}#{camera_owner}#{camera_ip}#{camera_model}#{camera_vendor}#{camera_username}#{camera_password}
                #{sorting(col_for_order, order_for)}")
    total_records = cameras.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = { data: [], draw: table_draw, recordsTotal: total_records, recordsFiltered: total_records }
    (display_start..index_end).each do |index|
      if cameras[index].present? && cameras[index]["user"].present?
        records[:data][records[:data].count] = [
          cameras[index]["created_at"] ? DateTime.parse(cameras[index]["created_at"]).strftime("%A, %d %b %Y %l:%M %p") : "",
          cameras[index]["exid"],
          cameras[index]["fullname"],
          cameras[index]["name"],
          cameras[index]["total_share"],
          JSON.parse(cameras[index]["config"]).deep_fetch("external_host") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("external_http_port") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("external_rtsp_port") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("auth", "basic", "username") { "" },
          JSON.parse(cameras[index]["config"]).deep_fetch("auth", "basic", "password") { "" },
          cameras[index]["mac_address"],
          cameras[index]["vendor_model_name"],
          cameras[index]["vendor_name"],
          cameras[index]["timezone"],
          cameras[index]["is_public"],
          cameras[index]["is_online"],
          cameras[index]["is_recording"],
          cameras[index]["last_poll_date"] ? DateTime.parse(cameras[index]["last_poll_date"]).strftime("%A, %d %b %Y %l:%M %p") : "",
          cameras[index]["id"],
          cameras[index]["user_id"],
          cameras[index]["api_id"],
          cameras[index]["api_key"],
          check_env
        ]
      end
    end
    render json: records
  end

  private

  def filter_camera(port, host, jpg)
    if !port.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and LOWER(config->'snapshots'->>'jpg') = ?", port, host, jpg)
    elsif port.blank? && host.blank? && jpg.blank?
      Camera.where("(config->'external_http_port') IS NULL and (config->'external_host') IS NULL and (config->'snapshots'->>'jpg') IS NULL")
    elsif port.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_host' = ? and LOWER(config->'snapshots'->>'jpg') = ? and (config->> 'external_http_port') IS NULL", host, jpg)
    elsif host.blank? && !port.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and LOWER(config->'snapshots'->>'jpg') = ?  and (config->> 'external_host') IS NULL ", port, jpg)
    elsif jpg.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and (config->'snapshots'->>'jpg') IS NULL", port, host)
    elsif port.blank? && host.blank? && !jpg.blank?
      Camera.where("LOWER(config->'snapshots'->>'jpg') = ? and (config->> 'external_http_port') IS NULL and (config->> 'external_host') IS NULL", jpg)
    elsif port.blank? && jpg.blank? && !host.blank?
      Camera.where("config->> 'external_host' = ? and (config->> 'external_http_port') IS NULL and (config->'snapshots'->>'jpg') IS NULL", host)
    elsif host.blank? && jpg.blank? && !port.blank?
      Camera.where("config->> 'external_http_port' = ? and (config->> 'external_host') IS NULL and (config->'snapshots'->>'jpg') IS NULL", port)
    elsif jpg.blank? && !host.blank? && !port.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and (config->'snapshots'->>'jpg') IS NULL", port, host)
    end
  end

  def delete_camera(ids)
    count = 0
    ids.each do |id|
      Camera.find(id).destroy
      count += 1
    end
    render json: count
  end

  def merge_camera(super_cam_id, super_cam_owner_id, camera_ids, owner_ids)
    success = 0
    camera_ids.each do |camera_id|
      going_to_merge_camera_share = CameraShare.where("camera_id = ?", camera_id)
      going_to_merge_camera_share.each do |share|
        begin
          share.update_attributes(camera_id: super_cam_id, sharer_id: super_cam_owner_id)
          success += 1
        rescue
          # ignoring
        end
      end
    end
    super_user = User.find(super_cam_owner_id)
    super_cam_exid = Camera.find(super_cam_id).exid
    super_owner_api_id = super_user.api_id
    super_owner_api_key =  super_user.api_key
    body = {}
    rights = "Snapshot,View,Edit,List"
    api = get_evercam_api(super_owner_api_id, super_owner_api_key)
    owner_ids.each do |owner_id|
      share_with_email = [User.find(owner_id).email]
      begin
        api.share_camera(super_cam_exid, share_with_email, rights, body)
        success += 1
      rescue
        # ignoring this
      end
    end
    Camera.where(id: camera_ids).destroy_all
    render json: success
  end

  def get_evercam_api(super_owner_api_id, super_owner_api_key)
    configuration = Rails.application.config
    parameters = { logger: Rails.logger }
    parameters = parameters.merge(
      api_id: super_owner_api_id,
      api_key: super_owner_api_key
    )
    settings = {}
    begin
      settings = (configuration.evercam_api || {})
    rescue
      # Deliberately ignored.
    end
    parameters = parameters.merge(settings) unless settings.empty?
    Evercam::API.new(parameters)
  end

  def sorting(col, order)
    case col
    when "1"
      "order by c.exid #{order}"
    when "2"
      "order by fullname #{order}"
    when "3"
      "order by c.name #{order}"
    when "4"
      "order by total_share #{order}"
    when "5"
      "order by c.config->> 'external_host' #{order}"
    when "6"
      "order by c.config->> 'external_http_port' #{order}"
    when "7"
      "order by c.config->> 'external_rtsp_port' #{order}"
    when "8"
      "order by c.config-> 'auth'-> 'basic'->> 'username' #{order}"
    when "9"
      "order by c.config-> 'auth'-> 'basic'->> 'password' #{order}"
    when "10"
      "order by c.mac_address #{order}"
    when "11"
      "order by vendor_model_name #{order}"
    when "12"
      "order by vendor_name #{order}"
    when "13"
      "order by c.timezone #{order}"
    when "14"
      "order by c.is_public #{order}"
    when "15"
      "order by c.is_online #{order}"
    when "16"
      "order by is_recording #{order}"
    when "17"
      "order by c.last_poll_date #{order}"
    when "0"
      "order by c.created_at #{order}"
    else
      "order by c.created_at desc"
    end
  end

  def cleanup_sorting(col, order)
    case col
    when "2"
      "order by c.last_online_at #{order}"
    when "3"
      "order by c.exid #{order}"
    when "4"
      "order by fullname #{order}"
    when "5"
      "order by owner_email #{order}"
    when "6"
      "order by c.name #{order}"
    when "7"
      "order by total_share #{order}"
    when "8"
      "order by c.config->> 'external_host' #{order}"
    when "9"
      "order by c.config->> 'external_http_port' #{order}"
    when "10"
      "order by c.config->> 'external_rtsp_port' #{order}"
    when "11"
      "order by c.config-> 'auth'-> 'basic'->> 'username' #{order}"
    when "12"
      "order by c.config-> 'auth'-> 'basic'->> 'password' #{order}"
    when "13"
      "order by c.is_public #{order}"
    when "14"
      "order by c.is_online #{order}"
    when "15"
      "order by cloud_recording_storage_duration #{order}"
    when "16"
      "order by cloud_recording_status #{order}"
    when "1"
      "order by c.created_at #{order}"
    else
      "order by c.created_at desc"
    end
  end
end
