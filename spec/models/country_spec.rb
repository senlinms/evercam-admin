require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :iso3166_a2 }
  end

  describe 'associations' do
  end

  it 'has a valid factory' do
    expect(build(:country)).to be_valid
  end
end