module Pages
  class UsersPage < Base

    def visit
      page.visit '/'
      click_link 'Users'
    end

    def sample_content
      'Username'
    end
  end
end
