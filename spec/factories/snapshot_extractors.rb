FactoryBot.define do
  sequence :requestor do |n|
    "requestor#{n}@evercam.io"
  end

  factory :snapshot_extractor do
    association :camera
    interval 300
    schedule "{\"Monday\":[\"8:0-17:30\"],\"Tuesday\":[\"8:0-17:30\"],\"Wednesday\":[\"8:0-17:30\"],\"Thursday\":[\"8:0-17:30\"],\"Friday\":[\"8:0-17:30\"]}"
    from_date "10/02/2018 11:00"
    to_date  "10/02/2018 11:30"
    requestor 
    status 0
  end
end
