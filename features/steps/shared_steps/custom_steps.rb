module SharedSteps
  module CustomSteps
    include Spinach::DSL

    step 'show me the page' do
      show_page
    end
  end
end