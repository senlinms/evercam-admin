module Pages
  class AdminPage < Base

    def visit
      page.visit '/admin'
    end

    def sample_content
      'Total cameras'
    end
  end
end
