class FrequentCategory < ActiveRecord::Base
	has_many :frequents, dependent: :destroy

	validates :name, presence: true, uniqueness: true
end
