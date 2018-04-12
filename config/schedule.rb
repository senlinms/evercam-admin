every 1.day, :at => '12:00 am' do
  runner "User.sync_users_tag(68815, 2)", environment: :production, :output => 'log/cron.log'
end

# every 10.minutes do
# 	runner "SnapshotExtractor.extract_snapshots", environment: :production
# end
