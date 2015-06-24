class Spinach::Features::IndexCameras < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'I visit camera section' do
    cameras_page.visit
  end

  step 'I should see all cameras' do
    expect(page).to have_content(cameras_page.sample_content)
  end
end
