module Pages
  class CameraPage < Base

    def visit(camera_id)
      page.visit "/cameras/#{camera_id}"
    end

    def sample_content
      'Camera Information'
    end
  end
end
