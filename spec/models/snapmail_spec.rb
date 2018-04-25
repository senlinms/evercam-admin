require 'rails_helper'

RSpec.describe Snapmail, type: :model do
  it 'has a valid factory' do
    expect(build(:snapmail)).to be_valid
  end
end
