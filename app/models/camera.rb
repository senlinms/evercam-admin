class Camera < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor_model, foreign_key: :model_id
  has_many :camera_shares

  validates :exid, presence: true
  validates :user, presence: true
  validates :is_public, presence: true
  validates :config, presence: true
  validates :name, presence: true
  validates :discoverable, presence: true
end
