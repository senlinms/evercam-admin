class SnapshotReport < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :camera

  def self.add_report
  	camera_report = Snapshot.connection.select_all("select camera_id,count(*) as snapshot_count from snapshots where created_at in (select created_at from snapshots where created_at >= '2016-01-18 00:00:00' and created_at <= '2016-01-18 23:59:59') group by camera_id").to_hash

  	camera_report.each do |camera|
  		SnapshotReport.create(camera_id: camera["camera_id"], snapshot_count: camera["snapshot_count"], report_date: "2016-01-18 00:00:00")
  	end
  end
end