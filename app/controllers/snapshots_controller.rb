class SnapshotsController < ApplicationController
  before_action :authorize_admin

  def index
  	@cameras = Camera.all.includes(:user)
  end

  def cloud_recordings
    @intercom = connect_intercom
    @cameras = Camera.connection.select_all("select c.name, c.exid, c.id cam_id, c.is_online, c.is_public, u.username,u.firstname, u.lastname, u.id user_id, u.api_id, u.api_key, u.payment_method ,cr.*,
      (select count(c1.id) from cameras c1 inner join cloud_recordings cr1 on c1.id=cr1.camera_id where owner_id=u.id and cr1.storage_duration=cr.storage_duration) total_cameras,
      (select sum(total_cameras) from licences l where l.user_id=u.id and l.storage=cr.storage_duration) licences
      from cloud_recordings cr
      inner join cameras c on cr.camera_id=c.id
      inner join users u on c.owner_id=u.id
      where cr.status <> 'off' order by u.username;")
  end
end
