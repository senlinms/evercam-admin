class SnapshotExtractorsController < ApplicationController

  def index

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
