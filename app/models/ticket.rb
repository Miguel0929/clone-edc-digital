class Ticket < ActiveRecord::Base

  validates_presence_of :element_id, :coach_id, :trainee_id, :category
  validates :element_id, uniqueness: { scope: [:coach_id, :category, :trainee_id] }

  enum category: [:inbox, :plantilla]
  
  scope :inboxes, -> { where(category: 0) }
  scope :refilables, -> { where(category: 1) }

end