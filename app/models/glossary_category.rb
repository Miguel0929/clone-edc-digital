class GlossaryCategory < ActiveRecord::Base
	has_many :glossaries, dependent: :destroy

	validates :title, presence: true, uniqueness: true

	def self.search(key)
		if key
			where('name ILIKE ?', "%#{key}%")
		else
			all
		end
	end
end
