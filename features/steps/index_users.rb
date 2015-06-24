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

  step 'that user has one camera' do
    camera
  end

  step 'I choose the user' do
    click_link 'Peter Dirty'
  end

  step 'I should see user details' do
    expect(page).to have_content 'User Summary'
    expect(page).to have_content 'First Name	Peter'
    expect(page).to have_content 'Last Name	Dirty'
    expect(page).to have_content "Username #{user.username}"
    expect(page).to have_content "API ID	#{user.api_id}"
    expect(page).to have_content "API Key	#{user.api_key}"
  end

  step "I should see user's cameras" do
    expect(page).to have_content 'Cameras Owned 1'
    expect_table_to_have_items_count 'datatable_ajax', 1
    expect(page).to have_content("#{camera.exid}	#{camera.name} Yes	Yes	#{camera.created_at.strftime("%d/%m/%y")}")
  end

  def user
    @user ||= FactoryGirl.create(:user, firstname: 'Peter', lastname: 'Dirty')
  end

  def camera
    @camera ||= FactoryGirl.create :camera, user: user
  end
end
