class CameraShareRequest < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"

  # Status constants.
  PENDING                   = -1
  CANCELLED                 = -2
  USED                      = 1
  ALL_STATUSES              = [USED, CANCELLED, PENDING]

  belongs_to :user, :foreign_key => 'user_id', :class_name => 'EvercamUser'
  belongs_to :camera

end