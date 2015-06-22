class Spinach::Features::IndexCameras < Spinach::FeatureSteps
  step 'I am logged in as admin' do
    User.all(&:destroy)
    camera_stubs(user)
    sign_in_page.visit
    sign_in_page.login_as(user.email, 'pass')
    expect(page).to have_content('Add a Camera')
  end

  step 'I am on admin panel' do
    admin_page.visit
    expect(page).to have_content(admin_page.sample_content)
  end

  step 'I visit camera section' do
    click 'Cameras'
  end

  step 'I should see all cameras' do
    expect(page).to have_content(camera_page.sample_content)
  end

  def user
    @user ||= FactoryGirl.create(:active_user, is_admin: true, password: 'pass')
  end
end
