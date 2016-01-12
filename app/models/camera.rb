class Camera < Sequel::Model
  # establish_connection "evercam_db_#{Rails.env}"

  # belongs_to :user, :foreign_key => 'owner_id', :class_name => 'EvercamUser'
  many_to_one :user, class: 'EvercamUser', key: :owner_id

  # belongs_to :vendor_model, :foreign_key => 'model_id', :class_name => 'VendorModel'
  many_to_one :vendor_model, class: 'VendorModel', key: :model_id

  # has_many :camera_shares, dependent: :delete_all
  one_to_many :camera_shares, class: 'CameraShare'


  # validates :exid, presence: true
  # validates :user, presence: true
  # validates :is_public, presence: true
  # validates :config, presence: true
  # validates :name, presence: true
  # validates :discoverable, presence: true

  def vendor
    vendor_model.vendor
  end

  # def snapshot_count
  #   Snapshot.where(camera_id: id).count
  # end

  def cloud_recording
    CloudRecording.find_by(camera_id: id)
  end

  def oldes_snapshot
    # Snapshot.where(camera_id: id).order(:created_at).last
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

  def self.run_sql(sql)
    Camera.connection.select_all(sql).to_hash
  end
end
