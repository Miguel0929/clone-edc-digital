class Mentors::EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_user
  before_action :set_program

  def index
  end

  def show
    @chapter = Chapter.find(params[:id])
    @answers = Answer.select(
      "answers.*, questions.question_text, count(comments.id) as comments_count, (select id from chapter_contents where coursable_id = questions.id and coursable_type = 'Question' limit 1) as chapter_content_id"
    )
    .joins(:question)
    .joins('left outer join comments on comments.answer_id = answers.id')
    .where('answers.question_id in (?) and answers.user_id = ?', @chapter.questions.pluck(:id), @user.id)
    .group('questions.id')
    .group('answers.id')

    #.joins("INNER JOIN chapter_contents on chapter_contents.coursable_id = questions.id and coursable_type = 'Question' ")
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_program
    @program = Program.find(params[:program_id])
  end
end
