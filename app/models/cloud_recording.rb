class CloudRecording < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"

  def validate
    super
    errors.add(:camera_id, "has not been set") unless camera_id
  end
end
