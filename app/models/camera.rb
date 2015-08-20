class Camera < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}"

  belongs_to :user, :foreign_key => 'owner_id', :class_name => 'EvercamUser'
  belongs_to :vendor_model, :foreign_key => 'model_id', :class_name => 'VendorModel'
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

  #TODO: this should be implemented
  def self.new_paid_cameras(months_ago)
    []
  end

  def self.total_paid_cameras(months_ago)
    []
  end
end
