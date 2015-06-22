class Country < ActiveRecord::Base
  validates :name, presence: true
  validates :iso3166_a2, presence: true
end
