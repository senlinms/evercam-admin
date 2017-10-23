FactoryBot.define do
  factory :vendor_model do
    association :vendor
    sequence(:name) { |n| "model#{n}" }
    config {{'some' => 'value'}}
    exid '21'
    jpg_url 'http://somewhere'
    mjpg_url 'http://somewhere'
    h264_url 'http://somewhere'
  end
end

