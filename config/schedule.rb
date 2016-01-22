# every 1.day, :at => '12:00 am' do
#   runner "SnapshotReport.add_report", environment: :production
# end
every :firday, :at => '12pm' do # Use any day of the week or :weekend, :weekday
  runner "SnapshotReport.add_report", environment: :production
end
