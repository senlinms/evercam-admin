class CamerasController < ApplicationController
  before_action :authorize_admin
  require 'evercam'

  def index
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
          camera.user["firstname"],
          camera.user["lastname"],
          camera.camera_shares.count,
          camera["is_online"],
          camera["created_at"],
          camera["is_public"],
          camera.user["id"]
        ]
      end
      render json: records
    elsif params[:super_cam_id] && params[:super_cam_owner_id] && params[:camera_ids] && params[:owner_ids]
      merge_camera(params[:super_cam_id], params[:super_cam_owner_id], params[:camera_ids], params[:owner_ids])
    else
      @cameras = Camera.run_sql("select count(nullif(is_online = false, true)) as online, config->>'external_http_port' as external_http_port, config->>'external_host' as external_host, LOWER(config->'snapshots'->>'jpg')   as jpg, count(*) as count from cameras group by config->>'external_http_port', config->>'external_host', LOWER(config->'snapshots'->>'jpg') HAVING (COUNT(*)>1)")
    end
  end

  def load_cameras
    condition = "lower(cameras.exid) like lower('%#{params[:fquery]}%') OR lower(cameras.name) like lower('%#{params[:fquery]}%') OR 
      lower(vm.name) like lower('%#{params[:fquery]}%') OR lower(v.name) like lower('%#{params[:fquery]}%')
      OR lower(users.firstname || ' ' || users.lastname) like lower('%#{params[:fquery]}%') OR 
      lower(cameras.config->>'external_host') like lower('%#{params[:fquery]}%')"
    cameras = Camera.joins("left JOIN users on cameras.owner_id = users.id")
                    .joins("left JOIN vendor_models vm on cameras.model_id = vm.id")
                    .joins("left JOIN vendors v on vm.vendor_id = v.id")
                    .where(condition).order("cameras.created_at").decorate
    total_records = cameras.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = { data: [], draw: table_draw, recordsTotal: total_records, recordsFiltered: total_records }

    (display_start..index_end).each do |index|
      records[:data][records[:data].count] = [
        cameras[index].exid,
        cameras[index].user.fullname,
        cameras[index].name,
        cameras[index].config.deep_fetch("external_host") { "" },
        cameras[index].config.deep_fetch("external_http_port") { "" },
        cameras[index].config.deep_fetch("external_rtsp_port") { "" },
        cameras[index].config.deep_fetch("auth", "basic", "username") { "" },
        cameras[index].config.deep_fetch("auth", "basic", "password") { "" },
        cameras[index].mac_address,
        cameras[index].vendor_model_name,
        cameras[index].vendor_name,
        cameras[index].is_public,
        cameras[index].is_online,
        cameras[index].creation_date,
        cameras[index].last_poll_date,
        cameras[index].id,
        cameras[index].user.id,
        cameras[index].user.api_id,
        cameras[index].user.api_key,
        check_env
      ]
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
    super_user = EvercamUser.find(super_cam_owner_id)
    super_cam_exid = Camera.find(super_cam_id).exid
    super_owner_api_id = super_user.api_id
    super_owner_api_key =  super_user.api_key
    body = {}
    rights = "Snapshot,View,Edit,List"
    api = get_evercam_api(super_owner_api_id, super_owner_api_key)
    owner_ids.each do |owner_id|
      share_with_email = EvercamUser.find(owner_id).email
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
end
