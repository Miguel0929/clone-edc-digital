class Dashboard::ChapterContentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chapter_content = ChapterContent.find(params[:id])

    if @chapter_content.coursable_type == 'Question'
      redirect_to new_dashboard_chapter_content_answer_path(@chapter_content)
    end
  end

end
