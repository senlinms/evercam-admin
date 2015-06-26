class CameraShare < ActiveRecord::Base
  belongs_to :camera
  belongs_to :user
  belongs_to :sharer, class: User

  validates :camera_id, presence: true
  validates :user, presence: true
  validates :kind, presence: true, length: { maximum: 50 }
end
