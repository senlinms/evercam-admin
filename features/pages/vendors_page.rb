module Pages
  class VendorsPage < Base

    def visit
      page.visit '/'
      click_link 'Vendors'
    end

    def sample_content
      'Add Vendor'
    end

    def add_vendor(attributes)
      fill_in 'vendor_exid', with: attributes[:exid]
      fill_in 'vendor_name', with: attributes[:name]
      fill_in 'vendor_known_macs', with: attributes[:known_macs]
      click_button 'Save'
    end
  end
end
