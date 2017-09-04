class Dashboard::QuizProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def router
    refilable=@chapter_content.model.refilables.find_by(user: current_user)
    if @chapter_content.model.refilables.find_by(user: current_user).nil?
      redirect_to new_dashboard_chapter_content_refilable_program_path(@chapter_content)
    else
      redirect_to dashboard_chapter_content_refilable_program_path(@chapter_content, refilable)
    end
  end

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
end
