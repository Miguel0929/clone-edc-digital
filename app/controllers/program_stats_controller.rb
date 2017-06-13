class ProgramStatsController < ApplicationController
	before_action :authenticate_user!

  def post
  	check = params[:src]
		user = params[:src2]
		program = params[:src3]
		@current_stats = ProgramStat.where(user_id: user, program_id: program).last

		if @current_stats.nil?
			@new_stats = ProgramStat.create(user_id: user, program_id: program, checked: 1)
		else
			if @current_stats.checked == 1
				@current_stats.update(checked: 0)
			else
				@current_stats.update(checked: 1)
			end
		end

		respond_to do |format|
			#format.html{ redirect_to mentor_student_path(user), notice: "Evaluación actualizada"}
			format.json{ head :ok}
			format.js{flash.now[:notice] = "my secret number "+rand(0,5)+" !"}
		end
  end

end
