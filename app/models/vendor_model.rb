class VendorModel < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  belongs_to :vendor
  has_many :camera

  validates :name, presence: true
  validates :exid, presence: true
  validates :jpg_url, presence: true
  validates :mjpg_url, presence: true
  validates :h264_url, presence: true
end
