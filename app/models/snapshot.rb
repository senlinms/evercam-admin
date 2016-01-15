class Snapshot < ActiveRecord::Base
	establish_connection "evercam_snapshot_db_#{Rails.env}".to_sym

  def self.upitize
  	snapshot.create(snapshot_id: "3", camera_id: "3", created_at: "2011-03-13 02:49:10")
  end
end
