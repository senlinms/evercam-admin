class Archive < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym
end
