require 'rails_helper'

RSpec.describe VendorModel, type: :model do
  describe 'validations' do
    pending
    it { should validate_presence_of :name }
    # it { should validate_presence_of :config }
    it { should validate_presence_of :exid }
    it { should validate_presence_of :jpg_url }
    it { should validate_presence_of :h264_url }
    it { should validate_presence_of :mjpg_url }
  end

  describe 'associations' do
    it { should belong_to(:vendor) }
  end

  it 'has a valid factory' do
    pending
    expect(build(:vendor_model)).to be_valid
  end
end
