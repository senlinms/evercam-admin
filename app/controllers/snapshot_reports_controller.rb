class SnapshotReportsController < ApplicationController

  def index
    if params[:date]
      date = params[:date]
    end
    @reports = SnapshotReport.includes(camera: [:user]).where(report_date: date)
    records = []
    @reports.each do |report|
      records[records.length] = [
        report.camera["name"],
        report.camera["exid"],
        report.camera.user["firstname"],
        report.camera.cloud_recording || { "storage_duration" => "" } ["storage_duration"],
        report.camera["is_online"],
        report["snapshot_count"],
        report.camera["id"],
        report.camera.user["id"],
        report.camera.user["lastname"],
      ]
    end
    if !records.blank?
      render json: records
    end
	end
end
