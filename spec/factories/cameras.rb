FactoryBot.define do
  factory :camera do
    sequence(:exid) { |n| "exid#{n}" }
    sequence(:name) { |n| "name#{n}" }
    mac_address "c8:f7:33:ca:4f:ea"
    association :user
    association :vendor_model
    is_public true
    is_online true
    discoverable true
    config({
               snapshots: {
                   jpg: '/onvif/snapshot'
               },
               auth: {
                   basic: {
                       username: 'abcd',
                       password: 'wxyz'
                   }
               },
               external_host: 'www.evercam.test',
               external_http_port: 80
           })
  end
end
