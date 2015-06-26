class Spinach::Features::IndexVendors < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'I visit vendors section' do
    vendors_page.visit
  end

  step 'I should see all vendors' do
    expect(page).to have_content(vendors_page.sample_content)
  end
end
