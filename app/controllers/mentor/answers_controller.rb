class Mentor::AnswersController < ApplicationController
	 before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :validate_coursable_type
  before_action :build_question

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :mentor_programs_path
	def router
    answer = build_answer
    redirect_to new_mentor_chapter_content_answer_path(@chapter_content)
  end

  def new
    @answer = build_answer
    @comments = @question.comments.where(owner: current_user).order(created_at: :asc)

    add_breadcrumb @chapter_content.chapter.program.name, mentor_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{mentor_chapter_content_path(@chapter_content)}'>#{@question.question_text}</a>".html_safe

  end

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
  def build_question
    @question = @chapter_content.model
  end
  def validate_coursable_type
    redirect_to root_url unless @chapter_content.coursable_type == 'Question'
  end
  def build_answer
    @question.answers.find_by(user: current_user, question: @question) || @question.answers.new(user: current_user)
  end
end
