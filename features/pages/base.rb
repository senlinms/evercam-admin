module Pages
  class Base
    include Capybara::DSL
    include FactoryBot::Syntax::Methods
  end
end
