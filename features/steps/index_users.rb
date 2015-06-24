class Spinach::Features::IndexUsers < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'I visit users section' do
    users_page.visit
  end

  step 'I should see all users' do
    expect(page).to have_content(users_page.sample_content)
  end
end
