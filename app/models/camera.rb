class Camera < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor_model
  has_many :camera_shares

  validates :exid, presence: true
  validates :user, presence: true
  validates :is_public, presence: true
  validates :config, presence: true
  validates :name, presence: true
  validates :discoverable, presence: true

  def vendor
    vendor_model.vendor
  end
  
  def self.created_months_ago(number)
    given_date = number.months.ago
    Camera.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end

  def self.paid_months_ago(number)

  end
end
