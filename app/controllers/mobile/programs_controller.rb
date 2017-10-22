class Mobile::ProgramsController < Mobile::BaseController
  before_action :authorize

  def index
    render json: programs, include: ['chapters', 'chapters.chapter_contents', 'chapters.chapter_contents.coursable']
  end

  private
  def programs
    current_user.group.programs.includes(chapters: [chapter_contents: [:coursable]])
  end
end
