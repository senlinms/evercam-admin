module Pages
  class CameraPage < Base

    def visit(camera_id)
      page.visit '/camera/#{camera_id}'
    end

    def sample_content
      'Owner'
    end
  end
end
