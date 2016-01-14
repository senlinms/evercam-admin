class Vendor < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  has_many :vendor_models

  validates :exid, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :known_macs, presence: true
end
