class SnapmailCamera < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :camera, :foreign_key => 'camera_id'
end
