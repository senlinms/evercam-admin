module Pages
  class SignInPage < Base

    def visit
      page.visit '/v1/users/signin'
    end

    def sample_content
      "I've forgotten my password"
    end

    def login_as(login, password)
      fill_in 'session_login', with: login
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    # fill_in "session_login", :with => user.email
    # fill_in "Password", :with => 'pass'
    # click_button "Sign in"
  end
end
