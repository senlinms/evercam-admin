class EvercamUser < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  self.table_name = "users"
  belongs_to :country
  has_many :cameras, :foreign_key => 'owner_id', :class_name => 'Camera'
  has_many :snapshots
  has_many :vendors
  has_many :camera_shares, :foreign_key => 'user_id', :class_name => 'CameraShare'


  def fullname
    "#{firstname} #{lastname}"
  end

  def self.created_months_ago(number)
    given_date = number.months.ago
    EvercamUser.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end
end
