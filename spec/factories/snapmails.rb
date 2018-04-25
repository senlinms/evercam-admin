FactoryBot.define do
  sequence :recipients do |n|
    "recipients#{n}@evercam.io"
  end

  factory :snapmail do
    sequence(:exid) { |n| "exid#{n}" }
    sequence(:subject) { |n| "title#{n}" }
    association :user
    is_public true
    notify_time "16:13"
    notify_days "Monday,Tuesday"
    recipients 
  end
end
