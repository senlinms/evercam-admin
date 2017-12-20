class SnapmailsHistory < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  self.table_name = "snapmails_history"
end
