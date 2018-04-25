require 'rails_helper'

RSpec.describe SnapshotExtractor, type: :model do
  describe 'validations' do
    it { should validate_presence_of :from_date }
    it { should validate_presence_of :to_date }
    it { should validate_presence_of :schedule }
    it { should validate_presence_of :requestor }
    it { should validate_presence_of :interval }
  end

  describe 'associations' do
    it { should belong_to(:camera) }
  end

  it 'has a valid factory' do
    expect(build(:snapshot_extractor)).to be_valid
  end
end
