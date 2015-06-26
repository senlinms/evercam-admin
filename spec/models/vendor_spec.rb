require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :exid }
    it { should validate_presence_of :known_macs }
  end

  describe 'associations' do
    it { should have_many(:vendor_models) }
  end

  it 'has a valid factory' do
    expect(build(:vendor)).to be_valid
  end
end
