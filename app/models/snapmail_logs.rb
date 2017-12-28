class SnapmailLogs < ActiveRecord::Base
  establish_connection "evercam_snapshot_db_#{Rails.env}".to_sym

  self.table_name = "snapmail_logs"
end
