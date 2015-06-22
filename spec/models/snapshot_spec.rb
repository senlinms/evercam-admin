require 'rails_helper'

RSpec.describe Snapshot, type: :model do
  describe 'validations' do
    it { should validate_presence_of :camera }
    it { should validate_presence_of :data }
    it { should validate_presence_of :is_public }
  end

  describe 'associations' do
    it { should belong_to(:camera) }
  end

  it 'has a valid factory' do
    expect(build(:snapshot)).to be_valid
  end
end
