require "evercam_misc"
Airbrake.configure do |config|
  config.ignore_environments = %w(development test)
  config.project_id = ENV["AIRBRAKE_ID"].to_i
  config.project_key = ENV["AIRBRAKE_KEY"]
end
