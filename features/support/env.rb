ENV['RAILS_ENV'] = 'test'
require './config/environment'

require 'rspec'
require 'rspec-rails'
require 'factory_bot'
require 'pry'
require 'database_cleaner'

require 'webmock'
include WebMock::API

FactoryBot.find_definitions
# WebMock.disable_net_connect!(:allow_localhost => true)

DatabaseCleaner.strategy = :truncation

Spinach.hooks.before_scenario do
  DatabaseCleaner.clean
  ActionMailer::Base.deliveries = []
end

Spinach.config.save_and_open_page_on_failure = false

Spinach::FeatureSteps.send(:include, RSpec::Matchers)
