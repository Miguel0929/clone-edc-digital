class Mobile::AnswersController < Mobile::BaseController
  after_action :update_program_stats, only: [:create, :update]

  def create
    answer = question.answers.new(answer_params)

    answer.user = current_user

    answer.answer_text = sanitize_answer if question.checkbox?

    answer.answer_text = answer.answer_text.strip

    answer.save

    render json: { status: :ok }
  end

  def update
    answer = Answer.find(params[:id])

    answer.answer_text = sanitize_answer if question.checkbox?

    answer.assign_attributes(answer_params)

    answer.answer_text = answer.answer_text.strip

    answer.save

    render json: { status: :ok }
  end

  private
  def question
    @question ||= Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:user_id, :question_id, :answer_text)
  end

  def sanitize_answer
    params[:answer][:answer_text].join('\n') if params[:answer][:answer_text].present?
  end

  def update_program_stats
    #program = Program.joins(:chapters => :chapter_contents).where(chapter_contents: {id: @chapter_content.id}).last
    program = ChapterContent.find_by(coursable: question ).chapter.program
    program_stat = ProgramStat.where(user_id: current_user.id, program_id: program.id).last
    progress = current_user.percentage_questions_answered_for(program)
    seen = current_user.percentage_content_visited_for(program)

    if program_stat.nil?
      new_stat = ProgramStat.create(user_id: current_user.id, program_id: program.id, program_progress: progress, program_seen: seen)
    else
      program_stat.update(program_progress: progress, program_seen: seen)
    end
  end
end
