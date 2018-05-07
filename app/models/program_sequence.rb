class ProgramSequence < ActiveRecord::Base
	belongs_to :group, dependent: :destroy
	serialize :sequence, Array
	validates :group_id, presence: true
end
