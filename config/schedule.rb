every 1.day, :at => '12:00 am' do
  runner "SnapshotReport.add_report", environment: :production
end

every 1.day, :at => '04:00 am' do
	runner "SnapshotExtractor.extract_snapshots", environment: :production
end
