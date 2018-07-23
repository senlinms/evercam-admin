class ApiController < ApplicationController
  skip_before_action :authenticate_user!, only: [:camera_by_contact]
  require 'evercam'

  def camera_by_contact
    cameras = []

    if params["shared-with"].present?
      cameras = Camera.connection.select_all("select distinct c.id,c.exid,c.name,c.timezone,c.is_online,c.is_public,c.created_at,c.last_online_at,
        cr.frequency,cr.storage_duration,u.api_id,u.api_key,
        (select count(id) as total from camera_shares cs where c.id=cs.camera_id) as total_share,
        (select count(*) from snapmail_cameras sc where sc.camera_id = c.id) snapmail_count
        from cameras c inner join camera_shares cs on c.id=cs.camera_id
        inner join users u on u.id=c.owner_id
        left join cloud_recordings cr on c.id=cr.camera_id
        where cs.user_id in (select id from users where email like '%#{params["shared-with"]}')
        or c.owner_id in (select id from users where email like '%azhar@evercam.io')")
    end
    render json: {data: cameras}
  end
end