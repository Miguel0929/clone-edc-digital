FactoryGirl.define do
  factory :program do
    name { Faker::Lorem.sentence }
  end
end
