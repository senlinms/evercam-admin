require 'evercam_misc'
Airbrake.configure do |config|
  config.project_id = ENV['AIRBRAKE_ID'].to_i
  config.project_key = ENV['AIRBRAKE_KEY']
end
