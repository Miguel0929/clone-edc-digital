FactoryGirl.define do
  factory :chapter do
    name { Faker::Lorem.sentence }
  end
end
