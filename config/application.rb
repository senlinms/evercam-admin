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
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

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
      snapshot_navigator_widget.js
      admin/admin.js
      metronic/components.css
      metronic/plugins.css
      metronic/layout.css
      metronic/profile.css
      metronic/default.css
      metronic/jquery.gritter.css
      metronic/uniform.default.css
      metronic/bootstrap-switch.min.css
      metronic/daterangepicker-bs3.css
      metronic/fullcalendar.css
      metronic/dataTables.bootstrap.css
      metronic/jqvmap.css
      metronic/tasks.css
      metronic/custom.css
      metronic/portfolio.css
      admin/admin.css
      views/widgets/widget.css
      views/widgets/add_camera.css
      bare-bones.js
      widgets.js
      widgets/add_camera.js
      widgets/localstorage_widget.js
      jquery.js
      phoenix.js
    ]
  end
end
