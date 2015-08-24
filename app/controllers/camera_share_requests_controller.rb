class CameraShareRequestsController < ApplicationController
  before_action :authorize_admin

  def index
    @share_requests = CameraShareRequest.all.includes(:user, :camera).decorate
  end
end