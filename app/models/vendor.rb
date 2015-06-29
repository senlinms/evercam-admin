class Vendor < ActiveRecord::Base
  has_many :vendor_models

  validates :name, presence: true, uniqueness: true
  validates :exid, presence: true, uniqueness: true
  validates :known_macs, presence: true
end
