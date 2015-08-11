class Snapshot < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"

  belongs_to :camera

  validates :camera, presence: true
  validates :data, presence: true
  validates :is_public, presence: true
end
