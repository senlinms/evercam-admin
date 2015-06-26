class Vendor < ActiveRecord::Base
  has_many :vendor_models

  validates :name, presence: true
  validates :exid, presence: true
  validates :known_macs, presence: true
end
