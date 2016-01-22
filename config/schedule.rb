# every 1.day, :at => '12:00 am' do
#   runner "SnapshotReport.add_report", environment: :production
# end
every 6.hours do
  runner "SnapshotReport.add_report", environment: :production
end
