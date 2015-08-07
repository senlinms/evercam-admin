class CameraShare < ActiveRecord::Base
  belongs_to :camera
  belongs_to :user
  belongs_to :sharer, :foreign_key => 'sharer_id', :class_name => 'User' #class: User, key: :sharer_id

  validates :camera_id, presence: true
  validates :user, presence: true
  validates :kind, presence: true, length: { maximum: 50 }
end
