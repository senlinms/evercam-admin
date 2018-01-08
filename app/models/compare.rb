class Compare < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :camera
  belongs_to :user, :foreign_key => 'requested_by', :class_name => 'EvercamUser'
end
