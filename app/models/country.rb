class Country < Sequel::Model
  # establish_connection "evercam_db_#{Rails.env}"

  one_to_many :users, class: 'EvercamUser'

  def self.by_iso3166(val)
    first(iso3166_a2: val)
  end
  # validates :name, presence: true
  # validates :iso3166_a2, presence: true
end
