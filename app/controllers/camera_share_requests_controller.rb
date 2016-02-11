class CameraShareRequestsController < ApplicationController
  before_action :authorize_admin

  def index
    @share_requests = CameraShareRequest.joins( :user, :camera ).decorate
  end
end
