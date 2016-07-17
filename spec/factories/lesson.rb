FactoryGirl.define do
  factory :lesson do
    identifier { Faker::Lorem.sentence }
    content { Faker::Lorem.sentence }
  end
end
