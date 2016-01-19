class SnapshotReport < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :camera

  def self.add_report
  	# select camera_id,count(*) as snapshot_count from snapshots where created_at in (select created_at from snapshots where created_at >= '2016-01-18 00:00:00' and created_at <= '2016-01-18 23:59:59') group by camera_id
  	SnapshotReport.create(camera_id: "7155", report_date: "2016-01-19 06:30:39.849939+00")
  end
end
