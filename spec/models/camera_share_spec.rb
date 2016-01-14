require 'rails_helper'

RSpec.describe CameraShare, type: :model do
  describe 'validations' do
    it { should validate_presence_of :camera_id }
    it { should validate_presence_of :user }
    it { should validate_presence_of :kind }
    it { should validate_length_of(:kind).is_at_most(50) }
  end

  describe 'associations' do
    it { should belong_to(:camera) }
    it { should belong_to(:user) }
    it { should belong_to(:sharer).class_name("EvercamUser") }
  end

  it 'has a valid factory' do
    pending
    expect(build(:camera_share)).to be_valid
  end
end