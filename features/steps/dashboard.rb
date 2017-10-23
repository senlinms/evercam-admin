class Spinach::Features::Dashboard < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'there is one new user' do
    user
  end

  step 'the user has one camera' do
    camera
  end

  step 'I should see indicators' do
    expect(page).to have_content 'Total Cameras'
    expect(page).to have_content 'Cameras added in the last 30 days'
    expect(page).to have_content 'Total Users'
    expect(page).to have_content 'Users registered in the last 30 days'
  end

  step 'I should see new cameras' do
    expect(page).to have_content "fooname #{camera.vendor_model.name} #{camera.vendor.name} #{camera.created_at.strftime("%d/%m/%y")}"
  end

  step 'I should see new users' do
    expect(page).to have_content 'New Users'
    expect(page).to have_content "Pietia Newman newman@go2.pl #{user.created_at.strftime("%d/%m/%y")}"
  end

  step 'I should see kpi' do
    expect(page).to have_content "New Cameras	0	0	0	0	0	0	0	0	0	0	0	1"
    expect(page).to have_content "Total Cameras	0	0	0	0	0	0	0	0	0	0	0	1"
    expect(page).to have_content "New Paid Cameras	0	0	0	0	0	0	0	0	0	0	0	0"
    expect(page).to have_content "Total Paid Cameras	0	0	0	0	0	0	0	0	0	0	0	0"
    expect(page).to have_content "New Users	0	0	0	0	0	0	0	0	0	0	0	2"
    expect(page).to have_content "Total Users	0	0	0	0	0	0	0	0	0	0	0	0"
  end

  def user
    @user ||= FactoryBot.create(:user, firstname: 'Pietia', lastname: 'Newman', email: 'newman@go2.pl')
  end

  def camera
    @camera ||= FactoryBot.create :camera, exid: 'fooid', name: 'fooname', user: user
  end
end
