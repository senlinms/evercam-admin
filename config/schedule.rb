
every 1.day, :at => '12:00 am' do
  runner "SnapshotReport.add_report", environment: :production
end

every 30.minutes do
	runner "SnapshotExtractor.extract_snapshots", environment: :production
end

every 3.minutes do
	command "echo 'you can use raw cron syntax too'"
end