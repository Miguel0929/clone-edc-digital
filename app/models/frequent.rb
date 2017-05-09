class Frequent < ActiveRecord::Base
	belongs_to :frequent_category

	validates :name, presence: true

	def self.category_of_frequents
		categories = FrequentCategory.all
		@array = [['SELECCIONA UNA CATEGORÍA']]

		categories.each do |cat|
			event = [cat[:name], cat[:id]]
			@array << event
		end

		@array
  end
end
