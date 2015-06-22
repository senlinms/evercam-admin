#
# This helper works better than save_and_open_page because it loads css and js properly
# See: https://coderwall.com/p/jsutlq
#
def show_page
  save_page Rails.root.join('public', 'capybara.html')
  %x(launchy http://localhost:3000/capybara.html)
end