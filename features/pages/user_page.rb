module Pages
  class UserPage < Base

    def visit(user_id)
      page.visit "/users/#{user_id}"
    end

    def click_change
      page.click_link 'Change'
    end

    def allow_admin_permissions
      choose 'Allow admin permissions'
      click_button 'Save'
    end

    def rename_to(name)
      fill_in 'user_firstname', with: name
      click_button 'Save'
    end

    def sample_content
      "User's Information"
    end
  end
end
