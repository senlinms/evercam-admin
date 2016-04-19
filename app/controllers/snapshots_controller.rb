class SnapshotsController < ApplicationController
  before_action :authorize_admin

  def index
  	@cameras = Camera.all.includes(:user)
  end

  def cloud_recordings
    @cameras = Camera.all.includes(:user)
    @intercom = connect_intercom
  end
end
