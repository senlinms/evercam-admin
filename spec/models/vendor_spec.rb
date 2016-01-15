require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'validations' do
    pending
    it { should validate_presence_of :name }
    it { should validate_presence_of :exid }
    it { should validate_presence_of :known_macs }
  end

  describe 'associations' do
    pending
    it { should have_many(:vendor_models) }
  end

  it 'has a valid factory' do
    pending
    expect(build(:vendor)).to be_valid
  end
end
