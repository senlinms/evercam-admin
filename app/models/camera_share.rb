class CameraShare < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :camera
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  belongs_to :sharer, :foreign_key => 'sharer_id', :class_name => 'User'

  validates :camera_id, presence: true
  validates :user, presence: true
  validates :kind, presence: true, length: { maximum: 50 }
end
