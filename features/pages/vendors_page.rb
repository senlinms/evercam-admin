module Pages
  class VendorsPage < Base

    def visit
      page.visit '/'
      click_link 'Vendors'
    end

    def sample_content
      'Add Vendor'
    end
  end
end
