class User < ActiveRecord::Base
  belongs_to :country
  has_many :cameras
  has_many :snapshots
  has_many :vendors
  has_many :camera_shares

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :username, presence: true
  validates :password, presence: true
  validates :email, presence: true

  def fullname
    "#{firstname} #{lastname}"
  end

  def self.created_months_ago(number)
    given_date = number.months.ago
    User.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end
end
