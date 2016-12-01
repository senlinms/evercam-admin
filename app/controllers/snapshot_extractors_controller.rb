class SnapshotExtractorsController < ApplicationController

  def index
    @cameras = Camera.where(owner_id: 13959).order("name").decorate
    @set_cameras = ["Select Camera", ""]
    @cameras.each do |camera|
      @set_cameras[@set_cameras.length] = [camera.name, camera.id]
    end
    @set_cameras
  end

  def list
    @snapshot_extractors = SnapshotExtractor.order("created_at DESC").all
  end

  def create
    status = 1
    SnapshotExtractor.create(
      camera_id: params[:camera_id],
      from_date: params[:from_date],
      to_date: params[:to_date],
      interval: params[:interval],
      schedule: params[:schedule],
      requestor: current_user.fullname
    )
    render json: status
  end
end
