module Pages
  class CameraPage < Base

    def visit
      page.visit '/admin/cameras'
    end

    def sample_content
      'Owner'
    end
  end
end
