module SharedSteps
  module CustomSteps
    include Spinach::DSL

    step 'show me the page' do
      show_page
    end

    def expect_table_to_have_items_count(table_name, items_count)
      expect(page.all("table##{table_name} tbody tr").count).to eq items_count
    end

    def expect_to_see_flash_message(message)
      expect(page).to have_selector '.alert', text: message
    end
  end
end