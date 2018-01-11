class ProgramStatsController < ApplicationController
  before_action :authenticate_user!

  def post
    check = params[:src]
    user = User.find(params[:src2])
    program = params[:src3]
    @current_stats = ProgramStat.where(user_id: user, program_id: program).last
    user.program_notifications.create({program_id: program, notification_type: 3})

    if user.panel_notifications.up_evaluation.first.nil? || user.panel_notifications.up_evaluation.first.status
      Programs.up_evaluation(Program.find(program),user,dashboard_evaluations_url(program_id: program))
    end
    
    if @current_stats.nil?
      @new_stats = ProgramStat.create(user_id: user.id, program_id: program, checked: 1, evaluation_date: Time.now, evaluating_mentor: current_user.email)
    else
      if @current_stats.checked == 1
	      @current_stats.update(checked: 0, evaluation_date: Time.now, evaluating_mentor: current_user.email)
      else
	      @current_stats.update(checked: 1, evaluation_date: Time.now, evaluating_mentor: current_user.email)
      end
    end

    prepared = user.ready_to_check?
    user.update(check_ready: prepared)

    respond_to do |format|
      #format.html{ redirect_to mentor_student_path(user), notice: "Evaluación actualizada"}
      format.json{ head :ok}
    end
  end

end
