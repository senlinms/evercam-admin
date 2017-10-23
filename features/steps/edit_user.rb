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

  step 'I try to rename user' do
    user_page.rename_to('Krzysiek')
  end

  step 'the user should become admin' do
    expect(page).to have_content 'Is Admin Yes Change'
  end

  step 'user\'s name should be changed' do
    expect(page).to have_content 'First Name	Krzysiek'
  end

  step 'I impersonate the user' do
    user_page.visit(user.id)
    user_page.impersonate
  end

  step 'I should have access to admin dashboard' do
    expect(page).to have_content(admin_page.sample_content)
  end

  def user
    @user ||= FactoryBot.create(:user, firstname: 'Peter', lastname: 'Dirty')
  end
end
