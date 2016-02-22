# set :output, 'cron_log.log'
every 1.day, :at => '12:00 am' do
  runner "SnapshotReport.add_report", environment: :production
end

every 30.minutes do
	runner "SnapshotExtractor.extract_snapshots", environment: :production
end

# every 2.minutes do
# 	runner "SnapshotExtractor.connect_bucket", environment: :development
# end
