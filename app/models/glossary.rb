class Glossary < ActiveRecord::Base
  mount_uploader :image, IllustrationUploader

  belongs_to :glossary_category

  validates :term, presence: true, uniqueness: true
  validates :definition, presence: true
  validates :glossary_category_id, presence: true

  	def self.category_of_glossaries
		categories = GlossaryCategory.all
		@array = []

		categories.each do |cat|
			event = [cat[:title], cat[:id]]
			@array << event
		end

		@array
	end

	def self.search(key)
		if key
			where('term ILIKE ?', "%#{key}%")
		else
			all
		end
	end
end
