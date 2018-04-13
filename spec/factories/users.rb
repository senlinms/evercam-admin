FactoryBot.define do
  sequence :email do |n|
    "email#{n}@evercam.io"
  end

  factory :user do
    sequence(:firstname) { |n| "firstname#{n}" }
    sequence(:lastname) { |n| "lastname#{n}" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:password) { |n| "password#{n}" }
    email
    sequence(:api_id) {|n| SecureRandom.hex(10)}
    sequence(:api_key) {|n| SecureRandom.hex(16)}
    
  end
end
