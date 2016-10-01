class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :track_chapter_content, only: [:show]

  def show
    if @chapter_content.coursable_type == 'Question'
      redirect_to router_dashboard_chapter_content_answers_path(@chapter_content)
    end
  end

  private
  def track_chapter_content
    @chapter_content = ChapterContent.find(params[:id])
    if Tracker.find_by(chapter_content: @chapter_content, user: current_user).nil?
      Tracker.create(chapter_content: @chapter_content, user: current_user)
    end
  end
end
