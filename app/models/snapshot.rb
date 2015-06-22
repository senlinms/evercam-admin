class Snapshot < ActiveRecord::Base
  belongs_to :camera

  validates :camera, presence: true
  validates :data, presence: true
  validates :is_public, presence: true
end
