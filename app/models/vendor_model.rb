class VendorModel < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"

  belongs_to :vendor

  validates :name, presence: true
  validates :exid, presence: true
  validates :jpg_url, presence: true
  validates :mjpg_url, presence: true
  validates :h264_url, presence: true
end
