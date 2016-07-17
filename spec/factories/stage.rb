FactoryGirl.define do
  factory :stage do
    name { Faker::Lorem.sentence }
  end
end
