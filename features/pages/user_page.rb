module Pages
  class UserPage < Base

    def visit(user_id)
      page.visit "/users/#{user_id}"
    end

    def click_change
      page.click_link 'Change'
    end

    def allow_admin_permissions
      choose 'user-rights-radios1'
      click_button 'Save'
    end

    def sample_content
      "User's Information"
    end
  end
end
