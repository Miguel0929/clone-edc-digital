class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chapter_content = ChapterContent.find(params[:id])

    if @chapter_content.coursable_type == 'Question'
      redirect_to router_dashboard_chapter_content_answers_path(@chapter_content)
    end
  end

end
