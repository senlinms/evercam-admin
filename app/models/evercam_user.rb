class EvercamUser < Sequel::Model(:users)
  # establish_connection "evercam_db_#{Rails.env}"

  # self = "users"
  # belongs_to :country
  many_to_one :country

  # has_many :cameras, :foreign_key => 'owner_id', :class_name => 'Camera'
  one_to_many :cameras, class: 'Camera', key: :owner_id

  # has_many :snapshots
  # has_many :vendors
  # has_many :camera_shares, :foreign_key => 'user_id', :class_name => 'CameraShare'
  one_to_many :camera_shares

  def fullname
    "#{firstname} #{lastname}"
  end

  def self.created_months_ago(number)
    given_date = number.months.ago
    EvercamUser.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end
end
