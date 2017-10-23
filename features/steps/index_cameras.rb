class Spinach::Features::IndexCameras < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'there is one camera' do
    camera
  end

  step 'I visit camera section' do
    cameras_page.visit
  end

  step 'I should see all cameras' do
    expect(page).to have_content(cameras_page.sample_content)
  end

  step 'I choose a camera' do
    click_link 'foobar'
  end

  step 'I should see camera details' do
    expect(page).to have_content(camera_page.sample_content)
    expect(page).to have_content "Owner	#{camera.user.fullname}"
  end

  def camera
    @camera ||= FactoryBot.create :camera, exid: 'foobar'
  end
end
