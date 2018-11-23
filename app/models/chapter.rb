class Chapter < ActiveRecord::Base
  validates_presence_of :name

  has_many :chapter_contents, -> { order(position: :asc) }, dependent: :destroy
  has_many :lessons, :through => :chapter_contents, :source => :coursable, :source_type => 'Lesson', dependent: :destroy
  has_many :questions, :through => :chapter_contents, :source => :coursable, :source_type => 'Question', dependent: :destroy
  has_many :content_chapters, :through => :chapter_contents, :source => :coursable, :source_type => 'Chapter', dependent: :destroy

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
      elsif content.coursable_type == 'Chapter'
        contenedor = content.model
        questions = contenedor.questions.count
        answers = Answer.where(question_id: contenedor.questions.pluck(:id), user_id: current_user.id).count  
        if questions == answers && questions > 0
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
    #self.chapter_contents.where(coursable_type: "Question").count
    questions = []
    self.chapter_contents.each do |chapter_content|
      if chapter_content.coursable_type == "Question"
        questions << chapter_content.model.id
      elsif chapter_content.coursable_type == "Chapter" 
        questions += chapter_content.model.questions.pluck(:id)   
      end  
    end
    return questions.length  
  end
  
  def get_cc_chapter
    ChapterContent.find_by(coursable_id: self.id, coursable_type: 'Chapter')
  end

  def all_questions
    questions = []
    self.chapter_contents.each do |chapter_content|
      if chapter_content.coursable_type == "Question"
        questions << chapter_content.model.id
      elsif chapter_content.coursable_type == "Chapter" 
        questions += chapter_content.model.questions.pluck(:id)   
      end  
    end
    q = Question.where(id: questions)
    q.sort_by { |x| questions.index(x.id) }
  end

  def points_earned(user)
    rubrics = self.evaluations
    puntos = 0; total = 0
    if rubrics.count > 0
      rubrics.each do |rubric|
        evaluation = rubric.user_evaluations.find_by(user_id: user.id)
        unless evaluation.nil?
          puntos += (evaluation.points * rubric.points) / 100
        end  
      end  
    end
    puntos
  end 

  def total_points
    rubrics = self.evaluations
    total = 0
    if rubrics.count > 0
      total = rubrics.sum(:points)
    end  
    total  
  end 

  def set_chapters_points
    unvalued_chapters = self.program.chapters.where(manual_points: false).includes(:chapter_contents).where(chapter_contents: {coursable_type: "Question"}).uniq
    valuated_chapters = self.program.chapters.where(manual_points: true)
    factor = self.id.nil? ? 1 : 0
    avg_value = ( ( 100 - valuated_chapters.pluck(:points).inject(0){|sum,x| sum + x } ) / ( unvalued_chapters.count + factor ) ) rescue 0
    unvalued_chapters.map{ |unch| unch.update(points: avg_value) }
    if (unvalued_chapters.count > 0) && (avg_value%unvalued_chapters.count != 0)
      total = ( unvalued_chapters.map{ |unch| unch.points } + valuated_chapters.pluck(:points) ).inject(0){|sum,x| sum + x } 
      unvalued_chapters.first.update(points: avg_value + (100 - total) )
    end
  end

end
