class Dashboard::RefilableProgramsController < ApplicationController
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
  def new
    @refilable=Refilable.new()
    @template=@chapter_content.model
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end
  def create
    @template=@chapter_content.model
    refilable = @template.refilables.new(refilable_params)
    refilable.user = current_user
    refilable.save

    redirect_to_next_content    
  end

  def show
    @refilable=@chapter_content.model.refilables.find_by(user: current_user)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def edit 
    @template=@chapter_content.model
    @refilable=@chapter_content.model.refilables.find_by(user: current_user)
    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def update
    @refilable = Refilable.find(params[:id])

    @refilable.update(refilable_params)

    redirect_to_next_content 
  end  

  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
  def refilable_params
    params.permit(:content)
  end
  def redirect_to_next_content
    program=@chapter_content.chapter.program
    mensaje= "Rellenable guardado con éxito"
    if @chapter_content.lower_item
      redirect_to dashboard_chapter_content_path(@chapter_content.lower_item), notice: mensaje
    elsif program.next_chapter(@chapter_content.chapter) && program.next_chapter(@chapter_content.chapter).chapter_contents.first
      redirect_to dashboard_chapter_content_path(program.next_chapter(@chapter_content.chapter).chapter_contents.first), notice: mensaje
    else
      redirect_to dashboard_program_path(program), notice: mensaje
    end
  end  
end
