class CameraShare < ActiveRecord::Base
  belongs_to :camera
  belongs_to :user
end
