module Pages
  class CamerasPage < Base

    def visit
      page.visit '/'
      click_link 'Cameras'
    end

    def sample_content
      'Owner'
    end
  end
end
