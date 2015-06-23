require 'rails_helper'

RSpec.describe Camera, type: :model do
  describe 'validations' do
    it { should validate_presence_of :exid }
    it { should validate_presence_of :user }
    it { should validate_presence_of :is_public }
    it { should validate_presence_of :config }
    it { should validate_presence_of :name }
    it { should validate_presence_of :discoverable }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:vendor_model) }
    it { should have_many(:camera_shares) }
  end

  it 'has a valid factory' do
    expect(build(:camera)).to be_valid
  end
end
