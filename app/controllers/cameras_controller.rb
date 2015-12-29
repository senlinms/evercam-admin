class CamerasController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.all.includes(:user, vendor_model: [:vendor]).decorate
  end

  def show
    @camera = Camera.find(params[:id]).decorate
  end

  def merge
    @cameras = Camera.run_sql("select count(nullif(is_online = false, true)) as online, config->>'external_http_port' as external_http_port, config->>'external_host' as external_host, config->'snapshots'->>'jpg'   as jpg, count(*) as count from cameras group by config->>'external_http_port', config->>'external_host', config->'snapshots'->>'jpg' HAVING (COUNT(*)>1)")
    if params[:port] && params[:host] && params[:jpg]
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
          camera["is_public"]
        ]
      end
      render json: records
    end
  end

  private

  def filter_camera(port, host, jpg)
    if !port.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and config->'snapshots'->>'jpg' = ?", port, host, jpg)
    elsif port.blank? && host.blank? && jpg.blank?
      Camera.where("(config->'external_http_port') IS NULL and (config->'external_host') IS NULL and (config->'snapshots'->>'jpg') IS NULL")
    elsif port.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_host' = ? and config->'snapshots'->>'jpg' = ? and (config->> 'external_http_port') IS NULL", host, jpg)
    elsif host.blank? && !port.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and config->'snapshots'->>'jpg' = ?  and (config->> 'external_host') IS NULL ", port, jpg)
    elsif jpg.blank? && !host.blank? && !jpg.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and (config->'snapshots'->>'jpg') IS NULL", port, host)
    elsif port.blank? && host.blank? && !jpg.blank?
      Camera.where("config->'snapshots'->>'jpg' = ? and (config->> 'external_http_port') IS NULL and (config->> 'external_host') IS NULL", jpg)
    elsif port.blank? && jpg.blank? && !host.blank?
      Camera.where("config->> 'external_host' = ? and (config->> 'external_http_port') IS NULL and (config->'snapshots'->>'jpg') IS NULL", host)
    elsif host.blank? && jpg.blank? && !port.blank?
      Camera.where("config->> 'external_http_port' = ? and (config->> 'external_host') IS NULL and (config->'snapshots'->>'jpg') IS NULL", port)
    elsif jpg.blank? && !host.blank? && !port.blank?
      Camera.where("config->> 'external_http_port' = ? and config->> 'external_host' = ? and (config->'snapshots'->>'jpg') IS NULL", port, host)
    end
  end
end
