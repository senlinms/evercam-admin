module Pages
  class CameraPage < Base

    def visit
      page.visit '/cameras'
    end

    def sample_content
      'Owner'
    end
  end
end
