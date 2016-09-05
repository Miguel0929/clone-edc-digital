FactoryGirl.define do
  factory :question do
    question_text  { Faker::Lorem.sentence }
    answer_options { Faker::Lorem.sentence }
    points { Faker::Number.number(1) }
  end
end
