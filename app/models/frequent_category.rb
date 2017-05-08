class FrequentCategory < ActiveRecord::Base
	has_many :frequents

	validates :name, presence: true, uniqueness: true
end
