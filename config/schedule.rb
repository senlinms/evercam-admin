every 1.day, :at => '12:00 am' do
  runner "SnapshotReport.add_report", environment: :production
end
