class Spinach::Features::IndexUsers < Spinach::FeatureSteps
  include SharedSteps::LoginSteps
  include SharedSteps::CustomSteps

  step 'there is one regular user' do
    user
  end

  step 'I visit users section' do
    users_page.visit
  end

  step 'I should see all users' do
    expect(page).to have_content(users_page.sample_content)
    expect_table_to_have_items_count 'datatable_ajax', 2
    expect(page).to have_content("Yes #{admin.username}	#{admin.fullname}	#{admin.email} 0	#{admin.created_at.strftime("%d/%m/%y")}	No")
    expect(page).to have_content("No #{user.username}	Peter Dirty	#{user.email}	0	#{user.created_at.strftime("%d/%m/%y")}	No")
  end

  def user
    @user ||= FactoryGirl.create(:user, firstname: 'Peter', lastname: 'Dirty')
  end
end
