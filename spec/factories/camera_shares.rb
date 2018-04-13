FactoryBot.define do
  factory :camera_share do
    association :camera
    association :user
    # association :sharer, class_name: "User"
    kind 'public'

    factory :public_camera_share do
      kind 'public'
    end

    factory :private_camera_share do
      kind 'private'
    end
  end
end
