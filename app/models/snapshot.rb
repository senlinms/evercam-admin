class Snapshot < ActiveRecord::Base
  :"evercam_snapshot_db_#{Rails.env}"
end
