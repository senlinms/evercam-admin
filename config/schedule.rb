every 1.day, :at => '12:00 am' do
  runner "SnapshotReport.add_report", environment: :production
end

# every 10.minutes do
# 	runner "SnapshotExtractor.extract_snapshots", environment: :production
# end
