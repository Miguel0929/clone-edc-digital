class StudentsStatesCoach < ActiveRecord::Base
	belongs_to :coach, :class_name => "User", foreign_key: "coach_id"
	belongs_to :state
end
