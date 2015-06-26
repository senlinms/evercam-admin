class Spinach::Features::AddVendor < Spinach::FeatureSteps
  include SharedSteps::LoginSteps

  step 'I am on vendors page' do
    vendors_page.visit
    expect(page).to have_content(vendors_page.sample_content)
  end

  step 'I try to add new vendor' do
    vendors_page.add_vendor(exid: 'fooid', name: 'fooname', known_macs: ['00:0E:53', '00:11:22'])
  end

  step 'the new vendor should be added' do
    pending 'step not implemented'
  end

end
