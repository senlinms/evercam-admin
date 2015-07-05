class HomeController < ActionController::Base
  layout 'devise'

  def no_access
    sign_out
  end
end
