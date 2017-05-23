class Mentor::ChapterContentsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_mentor
	def show
		@chapter_content=ChapterContent.find(params[:id])
		rank= Rating.where(ratingable_type: "ChapterContent", ratingable_id: @chapter_content.id, user_id: current_user.id).first
	    if rank.nil?
	      @rank=0
	    else
	      @rank=rank.rank
	    end  
	    if @chapter_content.coursable_type == 'Question'
	      redirect_to router_mentor_chapter_content_answers_path(@chapter_content), status: 301
	    else
	      add_breadcrumb "EDCDIGITAL", :root_path
	      add_breadcrumb @chapter_content.chapter.program.name, mentor_program_path(@chapter_content.chapter.program)
	      add_breadcrumb "<a class='active' href='#{mentor_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.identifier}</a>".html_safe
	    end
	end
end
