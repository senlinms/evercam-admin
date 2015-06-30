module Pages
  class SignInPage < Base

    def visit
      page.visit '/users/sign_in'
    end

    def sample_content
      "I've forgotten my password"
    end

    def login_as(login, password)
      fill_in 'user_email', with: login
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
