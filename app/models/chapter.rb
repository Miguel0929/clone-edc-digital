class Chapter < ActiveRecord::Base
  validates_presence_of :name, :points
  validates_numericality_of :points

  has_many :chapter_contents, -> { order(position: :asc) }, dependent: :destroy
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson', dependent: :destroy
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question', dependent: :destroy
  has_many :evaluations, -> { order(position: :asc) }
  belongs_to :program

  acts_as_list scope: :program

  accepts_nested_attributes_for :evaluations, reject_if: :all_blank, allow_destroy: true

  def get_chapter_progress(chapter, current_user)
    record = []
    viewed = []
    chapter_contents.each do |content|
  	  if content.coursable_type == 'Lesson'
        if current_user.trackers.find_by(chapter_content: content).nil?
          event = 0
          record << event
          viewed << event
        else
          event = 1
          record << event
          viewed << event
        end
      elsif content.coursable_type == 'Question'
        if current_user.has_answer_question?(content.model)
          event = 1
          record << event
        else
          event = 0
          record << event
        end
        if current_user.trackers.find_by(chapter_content: content).nil?
          event = 0
          viewed << event
        else
          event = 1
          viewed << event
        end
      end
    end
    #Calcular el porcentaje visto (percentage_viewed) y completado (percentage_done) de cada chapter
    total_record = record.size
    total_viewed = viewed.size
    record_ones = record.count(1)
    viewed_ones = viewed.count(1)
    if total_record > 0
      percentage_done = (record_ones.to_f / total_record.to_f * 100).round(0)
    else
      percentage_done = 0
    end
    if total_viewed > 0
      percentage_viewed = (viewed_ones.to_f / total_viewed.to_f * 100).round(0)
    else
      percentage_viewed = 0
    end
    #Etiquetar cada chapter como completo, incompleto o en progreso
    if record.detect {|i| i == 0}.nil? #si no hay ningún cero en el arreglo @record
      status = "complete"
    else
      if record.detect {|i| i == 1}.nil? #ahora pregunta si no hay ningún uno en @record
        status = "incomplete"
      else
        status = "progress"
      end
    end
    return status, percentage_done, percentage_viewed
  end

  def chapter_checked?(chapter, user)
    checked = Evaluation.joins(:user_evaluations).where(:user_evaluations => {:user_id => user}).where(chapter_id: chapter).count
    if checked > 0
      total = Evaluation.where(chapter_id: chapter).count
      return checked == total
    end
  end

  def lessons_count
    self.chapter_contents.where(coursable_type: "Lesson").count
  end

  def questions_count
    self.chapter_contents.where(coursable_type: "Question").count
  end

end
