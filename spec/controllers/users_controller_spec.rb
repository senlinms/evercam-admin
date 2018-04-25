require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  login_user

  it "should have a current_user" do
    expect(subject.current_user).to_not eq(nil)
  end

  it "should have current_user signed out" do
    sign_out subject.current_user
    expect(subject.current_user).to  be_nil
  end
end
