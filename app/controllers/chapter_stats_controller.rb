class ChapterStatsController < ApplicationController
	before_action :authenticate_user!

	def post
		check = params[:src]
		user = params[:src2]
		program = params[:src3]
		chapter = params[:src4]
		@current_stats = ChapterStat.where(user_id: user, chapter_id: chapter).last

		if @current_stats.nil?
			ChapterStat.create(user_id: user, chapter_id: chapter, checked: 1)
		else
			if @current_stats.checked == 1
				@current_stats.update(checked: 0)
			else
				@current_stats.update(checked: 1)
			end
		end

		respond_to do |format|
			#format.html{ redirect_to mentor_evaluation_path(chapter, program_id: program, user_id: user)}
			format.js
		end
	end

end
