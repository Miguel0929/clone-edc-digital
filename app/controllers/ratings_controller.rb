class RatingsController < ApplicationController
  before_action :authenticate_user!		
  def vote_chapter_content
  	@r=ChapterContent.find(params[:content_rating_id])
  	if @r.ratings.where(user_id: current_user.id,ratingable_type: "ChapterContent").nil?
  		@r.ratings.create(user_id: current_user.id,rank: params[:rating])
  	else
  		@r.ratings.where(user_id: current_user.id,ratingable_type: "ChapterContent").first.update(rank: params[:rating])
  	end	
  	render json: {"status" => "ok"}
  end
  def vote_chapter

  end  
end
