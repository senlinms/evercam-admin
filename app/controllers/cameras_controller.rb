class CamerasController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.all.includes(:user, vendor_model: [:vendor]).decorate
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
    Camera.where(id: camera_ids).destroy_all
    render json: success
    pry
    # super_user = EvercamUser.find(super_cam_owner_id)
    # super_owner_api_id = super_user.api_id
    # super_owner_api_key =  super_user.api_key
    # body = {}
    # body[:message] = ""
    # body[:grantor] = super_user.username
    # rights = ["grant~list","grant~edit","edit","grant~view,view","grant~snapshot","snapshot","list"]
    # api = get_evercam_api(super_owner_api_id, super_owner_api_key)

    # camera_ids.zip(owner_ids).each do |camera_id, owner_id|
    #   share_with_email = EvercamUser.find(owner_id).email
    #   begin
    #     api.share_camera(camera_id, share_with_email, rights, body)
    #   rescue
    #     # ignoring this
    #   end
    # end

    # render json: success
    # @mergeme = CameraShare.where("camera_id = ?", mergeMe)
    # @mergewith = Camera.find(mergeIn)
    # @mergeme.each do |cam|
    #   begin
    #     cam.update_attribute(:camera_id, @mergewith.id)
    #     cam.update_attribute(:sharer_id, @mergewith.owner_id)
    #     mergs += 1
    #   rescue
    #     dups += 1
    #   end
    # end
    # render json: { mergs: mergs, dups: dups }
    # Camera.find(mergeMe).destroy
  end

  def get_evercam_api(super_owner_api_id, super_owner_api_key)
    configuration = Rails.application.config
    parameters = {logger: Rails.logger}
    if current_user
      parameters = parameters.merge(
        api_id: super_owner_api_id,
        api_key: super_owner_api_key
      )
    end
    settings = {}
    begin
      settings = (configuration.evercam_api || {})
    rescue => _error
      # Deliberately ignored.
    end
    parameters = parameters.merge(settings) if !settings.empty?
    Evercam::API.new(parameters)
  end
end
