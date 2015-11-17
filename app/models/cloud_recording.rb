class CloudRecording < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"
  #belongs_to :camera, :foreign_key => 'camera_id'

  def validate
    super
    errors.add(:camera_id, 'has not been set') if !camera_id
  end
end