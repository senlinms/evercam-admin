class SnapshotExtractorsController < ApplicationController

  def index
  	@cameras = Camera.all.includes(:user, vendor_model: [:vendor]).decorate
  	@set_cameras = ["Select Camera",""]
  	@cameras.each do |camera|
  		@set_cameras[@set_cameras.length] = [
  			camera.exid, camera.id
  		]
  	end
  	@set_cameras
  end

  def create
  	status = 1
  	SnapshotExtractor.create(
			camera_id: params[:camera_id],
			from_date: params[:from_date],
			to_date: params[:to_date],
			interval: params[:interval],
			schedule: params[:schedule]
  	)
  	render json: status
  end
end
