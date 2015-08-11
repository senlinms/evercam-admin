class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :country

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :username, presence: true
  validates :encrypted_password, presence: true

  def fullname
    "#{firstname} #{lastname}"
  end

  def self.created_months_ago(number)
    given_date = number.months.ago
    User.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end
end
