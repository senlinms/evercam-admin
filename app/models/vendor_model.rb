class VendorModel < ActiveRecord::Base
  belongs_to :vendor

  validates :name, presence: true
  validates :config, presence: true
  validates :exid, presence: true
  validates :jpg_url, presence: true
  validates :mjpg_url, presence: true
  validates :h264_url, presence: true
end
