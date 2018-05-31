class UserTrainee < ActiveRecord::Base
	belongs_to :user
	belongs_to :trainee, class_name: "User"

	validates :user_id, uniqueness: { scope: [:trainee_id] }
end