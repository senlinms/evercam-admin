module Pages
  class AdminPage < Base

    def visit
      page.visit '/'
    end

    def sample_content
      'Total Cameras'
    end
  end
end
