class Chapter < ActiveRecord::Base
  validates_presence_of :name, :points
  validates_numericality_of :points

  has_many :chapter_contents, -> { order(position: :asc) }, dependent: :destroy
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson', dependent: :destroy
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question', dependent: :destroy
  has_many :evaluations
  belongs_to :program

  acts_as_list scope: :program

  accepts_nested_attributes_for :evaluations, reject_if: :all_blank, allow_destroy: true

  def get_chapter_progress(chapter, current_user)
    record = []
    chapter_contents.each do |content|
  	  if content.coursable_type == 'Lesson'
        if current_user.trackers.find_by(chapter_content: content).nil?
          event = 0
          record << event
        else
          event = 1
          record << event
        end
      elsif content.coursable_type == 'Question'
        if current_user.trackers.find_by(chapter_content: content).nil?
          event = 0
          record << event
        else
          event = 1
          record << event
        end
      end
    end
    if record.detect {|i| i == 0}.nil? #si no hay ningún cero en el arreglo @record
      status = "complete"
    else
      if record.detect {|i| i == 1}.nil? #ahora pregunta si no hay ningún uno en @record
        status = "incomplete"
      else
        status = "progress"
      end
    end
    return status
  end

end
