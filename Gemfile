source 'https://rubygems.org'

fail 'Ruby version must be greater than 2.0' unless RUBY_VERSION.to_f > 2.0

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 3.0.0'
gem 'yui-compressor'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'

gem 'sprockets'
gem 'sprockets-es6', require: 'sprockets/es6'
# gem 'fog'
# gem 'asset_sync'
gem 'autoprefixer-rails'
gem 'rake'

gem 'stripe',
    github: 'stripe/stripe-ruby'
gem 'stripe_event'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap', '~> 3.3.1'
  gem 'rails-assets-bootstrap-datepicker', '~> 1.3.1'
  gem 'rails-assets-bootstrap-tabdrop', '~> 1.0.0'
  gem 'rails-assets-datatables', '~> 1.10.4'
  gem 'rails-assets-datatables-plugins', '~> 1.0'
  gem 'rails-assets-datetimepicker', '~> 2.4.1'
  gem 'rails-assets-iCheck', '~> 1.0.2'
  gem 'rails-assets-jquery-cookie', '~> 1.4.1'
  gem 'rails-assets-jquery-form-validator', '~> 2.1.47'
  gem 'rails-assets-jquery.browser', '~> 0.0.7'
  gem 'rails-assets-jquery.nicescroll', '~> 3.5.6'
  gem 'rails-assets-jquery.uniform', '~> 2.1.2'
  gem 'rails-assets-ladda', '~> 0.8.0'
  gem 'rails-assets-moment', '~> 2.8'
end

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

gem 'geocoder'
gem 'georuby'
# Use Puma as the app server
gem 'puma'

# Use Draper for decorators
gem 'draper'

gem 'devise'
gem 'dotenv'

group :development, :test do
  gem 'pry'
  gem 'factory_girl_rails', require: false
  gem 'rspec-rails'
  gem 'rspec'
  gem 'spinach-rails'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-nginx'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', '~>1.3.0'
  gem 'capistrano-rails-db'
  gem 'capistrano-rails-console'
  gem 'capistrano-upload-config'
  gem 'sshkit-sudo'
end

group :test do
  gem 'capybara', '~>2.14.3'
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'nokogiri', '~>1.8.0'
  gem 'vcr'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem "codeclimate-test-reporter", :require => nil
end

group :evercam do
  gem 'evercam',
    github: 'evercam/evercam-ruby'
end
gem 'whenever', :require => false

gem 'aws-sdk-v1'
gem 'rmega', '~> 0.2.2'

gem 'intercom'
gem "bcrypt"
gem 'spawnling', '~>2.1'
