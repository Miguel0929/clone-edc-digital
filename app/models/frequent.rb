class Frequent < ActiveRecord::Base
	belongs_to :frequent_category

	validates :name, presence: true
	validates :frequent_category_id, presence: true

	def self.category_of_frequents
		categories = FrequentCategory.all
		@array = []

		categories.each do |cat|
			event = [cat[:name], cat[:id]]
			@array << event
		end

		@array
	end

	def self.search(term)
		if term
			where('name ILIKE ?', "%#{term}%")
		else
			all
		end
	end
end
