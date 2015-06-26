ENV['RAILS_ENV'] = 'test'
require './config/environment'

require 'rspec'
require 'rspec-rails'
require 'factory_girl'
require 'pry'
require 'database_cleaner'

require 'webmock'
include WebMock::API

FactoryGirl.find_definitions
# WebMock.disable_net_connect!(:allow_localhost => true)

DatabaseCleaner.strategy = :truncation

Spinach.hooks.before_scenario do
  DatabaseCleaner.clean
  ActionMailer::Base.deliveries = []
end

Spinach.config.save_and_open_page_on_failure = false

Spinach::FeatureSteps.send(:include, RSpec::Matchers)
