class RankController < ApplicationController
  before_action :authenticate_user!		
  def vote
  	@r=ChapterContentRank.where(user_id: current_user.id,chapter_content_id: params[:chapter_content_id])
  	if @r.length==0
  		@rank=ChapterContentRank.create(user_id: current_user.id,chapter_content_id: params[:chapter_content_id],rank: params[:rating])
  	else
  		@rank=@r.first
  		@rank.update(chapter_content_id: params[:chapter_content_id],rank: params[:rating])
  	end	
  	render json: ok
  end
end
