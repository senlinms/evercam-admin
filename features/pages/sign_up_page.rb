module Pages
  class SignUpPage < Base

    def visit
      page.visit '/users/sign_up'
    end

    def sample_content
      'Create a free Account'
    end

    def sign_up(attributes)
      fill_in 'user_firstname', with: attributes[:firstname]
      fill_in 'user_lastname', with: attributes[:lastname]
      fill_in 'user_username', with: attributes[:username]
      fill_in 'user_email', with: attributes[:email]
      fill_in 'user_password', with: attributes[:password]
      click_button 'Create New Account'
    end
  end
end
