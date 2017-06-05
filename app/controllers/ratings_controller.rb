class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show]
  before_action :require_admin, only: [:show]
  add_breadcrumb "EDCDIGITAL", :root_path
  def show
    add_breadcrumb "Programas", :programs_path
    add_breadcrumb "<a class='active' href='#{rating_program_path}'>Ratings</a>".html_safe
  end		
  def vote_chapter_content
  	@r=ChapterContent.find(params[:content_rating_id])
  	if @r.ratings.where(user_id: current_user.id,ratingable_type: "ChapterContent").count==0
  		@r.ratings.create(user_id: current_user.id,rank: params[:rating])
  	else
  		@r.ratings.where(user_id: current_user.id,ratingable_type: "ChapterContent").first.update(rank: params[:rating])
  	end	
  	render json: {"status" => "ok"}
  end
  def vote_program
    @r=Program.find(params[:content_rating_id])
    if @r.ratings.where(user_id: current_user.id,ratingable_type: "Program").count==0
      @r.ratings.create(user_id: current_user.id,rank: params[:rating])
    else
      @r.ratings.where(user_id: current_user.id,ratingable_type: "Program").first.update(rank: params[:rating])
    end 
    render json: {"status" => "ok"}
  end 
  private
  def set_program
    @program = Program.find(params[:id])
  end
end
