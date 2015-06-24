require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :username }
    it { should validate_presence_of :password }
    it { should validate_presence_of :email }
  end

  describe 'associations' do
    it { should belong_to(:country) }
    it { should have_many(:camera_shares) }
  end

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end
end
