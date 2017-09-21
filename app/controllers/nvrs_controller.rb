class NvrsController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.where(owner_id: 13959).order("name")
    @evercam_server = evercam_server
  end

  def vh
    @cameras = Camera.where(owner_id: 13959).order("name")
    @evercam_server = evercam_server
  end

  def snapshot_extractor
    @cameras = Camera.where(owner_id: [13959, 109148]).order("name").decorate
    @evercam_server = evercam_server
    @user_email = current_user.email
  end
end