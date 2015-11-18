class Snapshot < ActiveRecord::Base
  establish_connection "evercam_snapshot_db_#{Rails.env}"
end
