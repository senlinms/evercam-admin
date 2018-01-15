class Snapmail < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :user, :foreign_key => 'user_id', :class_name => 'EvercamUser'
  has_many :snapmail_cameras, :foreign_key => 'snapmail_id'
end
