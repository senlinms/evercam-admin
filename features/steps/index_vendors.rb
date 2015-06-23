class Spinach::Features::IndexVendors < Spinach::FeatureSteps
  step 'I visit vendors section' do
    visit '/vendors'
  end

  step 'I should see all vendors' do
    show_page
  end
end
