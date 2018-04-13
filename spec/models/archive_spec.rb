require 'rails_helper'

RSpec.describe Archive, type: :model do
  describe 'validations' do
    
  end

  describe 'associations' do
    it { should belong_to(:camera) }
    it { should belong_to(:user) }
  end

  it 'has a valid factory' do
    expect(build(:archive)).to be_valid
  end
end
