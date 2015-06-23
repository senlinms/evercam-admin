class Spinach::Features::IndexUsers < Spinach::FeatureSteps
  step 'I visit users section' do
    visit '/users'
  end

  step 'I should see all users' do
    show_page
  end
end
