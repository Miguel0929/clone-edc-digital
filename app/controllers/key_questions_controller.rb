class KeyQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  add_breadcrumb "EDCDIGITAL", :root_path
  
  def index
  	add_breadcrumb "<a href='#{key_questions_path}' class='active'>Preguntas clave del contenido</a>".html_safe
  	@keys = KeyQuestion.all
  end

  def create
    question = Question.find(params[:question_id])
    prev  = KeyQuestion.find_by(coursable_id: question.id)
    if prev.nil?
      KeyQuestion.create(coursable_id: question.id, chapter_content_id: ChapterContent.find_by(coursable_id: question.id).id)
      redirect_to key_questions_path, notice: "Una pregunta clave fue agregada con éxito"
    else
      redirect_to key_questions_path, notice: "La pregunta ya fue marcada como clave previamente"
    end
  end

  def destroy
  	KeyQuestion.find(params[:id]).destroy
    redirect_to key_questions_path, notice: "La marca de pregunta clave fue eliminada con éxito"
  end

  def populate_chapter_options
    program = Program.find(params[:program_id])
    if !program.nil?
      arry = program.chapters.pluck(:id, :name)
    else
      arry = []
    end
    render :json => arry.to_json
  end

  def populate_content_options
    chapter = Chapter.find(params[:chapter_id])
    if !chapter.nil?
      contents = chapter.chapter_contents.where(coursable_type: "Question").pluck(:coursable_id)
      if contents.empty?
        arry = []
      else
        arry = []
        contents.each do |con|
          arry.push([con, Question.find(con).question_text])
        end
      end
    else
      arry = []
    end
    render :json => arry.to_json
  end
end
