FactoryBot.define do
  factory :archive do
    sequence(:exid) { |n| "exid#{n}" }
    sequence(:title) { |n| "title#{n}" }
    association :camera
    association :user
    from_date "10/02/2018 11:00"
    to_date  "10/02/2018 11:30"
    status 0
  end
end
