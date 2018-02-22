class CameraShareRequestsController < ApplicationController
  before_action :authorize_admin

  def index
    @share_requests = CameraShareRequest.joins(:user, :camera).decorate
  end

  def delete
    CameraShareRequest.connection.select_all("delete from camera_share_requests where id in (#{params["ids"]})")
    render json: {success: true}
  end
end
