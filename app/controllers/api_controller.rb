class ApiController < ApplicationController
  skip_before_action :authenticate_user!, only: [:camera_by_contact]
  require 'evercam'

  def camera_by_contact
    cameras = []

    if params["shared-with"].present?
      cameras = Camera.connection.select_all("select distinct c.id,c.exid,c.name,c.timezone,c.is_online,c.is_public,c.created_at,c.last_online_at,c.mac_address,
        c.config->>'external_http_port' as http_port,c.config->>'external_rtsp_port' as rtsp_port, c.config->>'external_host' as host, LOWER(config->'snapshots'->>'jpg') as jpg,
        c.config->'auth'->'basic'->>'password' as cam_password,c.config->'auth'->'basic'->>'username' as cam_username from cameras c inner join camera_shares cs on c.id=cs.camera_id
        where cs.user_id in (select id from users where email like '%#{params["shared-with"]}')")
    end
    render json: {data: cameras}
  end
end