module Pages
  class Base
    include Capybara::DSL
    include FactoryGirl::Syntax::Methods
  end
end
