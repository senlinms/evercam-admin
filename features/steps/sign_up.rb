class Spinach::Features::SignUp < Spinach::FeatureSteps

  step 'I try to access admin dashboard' do
    admin_page.visit
  end

  step 'I am redirected to login page' do
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
    expect(page).to have_content(sign_in_page.sample_content)
  end

  step 'I try to sign up' do
    click_link 'Create New Account'
    expect(page).to have_content(sign_up_page.sample_content)
    sign_up_page.sign_up(
      firstname: 'Smith',
      lastname: 'Wigglesworth',
      username: 'swigglesworth',
      email: 'sw@go2.pl',
      password: 'password1'
    )
  end

  step 'my user account should be created' do
    expect(page).to have_content 'You have signed up successfully.'
  end

  step 'I still have no access to admin dashboard' do
    admin_page.visit
    expect(page).to have_content(sign_in_page.sample_content)
  end

end
