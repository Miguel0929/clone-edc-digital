FactoryGirl.define do
  factory :question do
    question_text  { Faker::Lorem.sentence }
    answer_options { Faker::Lorem.sentence }
  end
end
