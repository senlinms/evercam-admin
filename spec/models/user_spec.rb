require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :username }
    it { should validate_presence_of :password }

    describe 'email uniqueness' do
      before { create :user, email: 'foo@bar.com' }
      let(:user) { build :user, email: 'foo@bar.com' }
      it do
        user.valid?
        expect(user.errors[:email]).to be == ['has already been taken']
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:country) }
    it { should have_many(:camera_shares) }
  end

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end
end
