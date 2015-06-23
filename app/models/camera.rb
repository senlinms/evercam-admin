class Camera < ActiveRecord::Base
  belongs_to :owner, class: User
  belongs_to :vendor_model, class: VendorModel
  has_many :camera_shares

  validates :exid, presence: true
  validates :owner_id, presence: true
  validates :is_public, presence: true
  validates :config, presence: true
  validates :name, presence: true
  validates :discoverable, presence: true
end
