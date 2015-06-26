module SharedSteps
  module LoginSteps
    include Spinach::DSL

    step 'I am logged in as admin' do
      # TODO: uncomment when authentication is ready
      # sign_in_page.visit
      # sign_in_page.login_as(user.email, 'pass')
      admin
    end

    step 'I am on admin dashboard' do
      admin_page.visit
      expect(page).to have_content(admin_page.sample_content)
    end

    def admin
      @admin ||= FactoryGirl.create(:user, is_admin: true, password: 'pass')
    end
  end
end

