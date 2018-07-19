require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EvercamAdmin
  class Application < Rails::Application

    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => 'https://67000000195211.zappsusercontent.com',
      'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
    }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Dublin'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    GC::Profiler.enable

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = true

    config.assets.paths << "#{Rails.root.to_s}/vendor/assets/fonts"
    config.assets.paths << "#{Rails.root.to_s}/vendor/assets/javascripts"
    config.assets.paths << "#{Rails.root.to_s}/lib/assets/javascripts"
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif *.svg]
    config.assets.precompile += %w[
      admin/admin.js
      admin/admin.css
      jquery.js
      phoenix.js
    ]
  end
end
