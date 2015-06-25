class Spinach::Features::EditUser < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'there is one regular user' do
    user
  end

  step 'I am on user\'s page' do
    user_page.visit(user.id)
    expect(page).to have_content(user_page.sample_content)
  end

  step 'I try to grant admin rights' do
    user_page.click_change
    expect(page).to have_content 'User Details'
    user_page.allow_admin_permissions
  end

  step 'the user should become admin' do
    pending 'step not implemented'
  end

  def user
    @user ||= FactoryGirl.create(:user, firstname: 'Peter', lastname: 'Dirty')
  end
end
