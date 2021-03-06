require "bcrypt"
require 'intercom'

class EvercamUsers < ActiveRecord::Base
  establish_connection "evercam_db_#{Rails.env}".to_sym

  include BCrypt
  before_save :create_hashed_password, if: :password_changed?

  self.table_name = "users"
  belongs_to :country
  has_many :cameras, :foreign_key => 'owner_id', :class_name => 'Camera'
  has_many :snapshots
  has_many :vendors
  has_many :camera_shares, :foreign_key => 'user_id', :class_name => 'CameraShare'
  has_many :licences, foreign_key: 'user_id', class_name: 'Licence'

  validates_length_of :password, minimum: 6, if: :password_changed?

  def fullname
    "#{firstname} #{lastname}"
  end

  def self.created_months_ago(number)
    given_date = number.months.ago
    User.where(created_at: given_date.beginning_of_month..given_date.end_of_month)
  end

  def create_hashed_password
    if password
      self.password = Password.create(password, cost: 10)
    end
  end

  def self.sync_users_tag(tag_id, payment_type)
    intercom = Intercom::Client.new(token: ENV["INTERCOM_KEY"])
    users = intercom.users.find(tag_id: tag_id)

    (1..users.pages.total_pages.to_i).each do |page|
      unless page == 1
        users = intercom.users.find(tag_id: tag_id, page: page)
      end
      users.users.each do |ic_user|
        db_user = User.find_by_email(ic_user["email"])
        if db_user.present? && !db_user.payment_method.equal?(payment_type)
          db_user.update_attributes(
              payment_method: payment_type,
              updated_at: Time.now
          )
          puts "user #{db_user.email} - #{db_user.id}"
          puts "------------------------------------------------"
        end
      end
    end
    puts "Task finished"
  end
end
