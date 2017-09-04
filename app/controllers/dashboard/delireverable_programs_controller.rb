class Dashboard::DelireverableProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter_content
  before_action :set_delireverables_package, only: [:new, :create, :show, :edit, :update]

  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "programas", :dashboard_programs_path

  def router
    paquete=@chapter_content.model
    p paquete.delireverables_sent(current_user)  
    if paquete.delireverables_sent(current_user)
      redirect_to dashboard_chapter_content_delireverable_program_path(@chapter_content, paquete)
    else
      redirect_to new_dashboard_chapter_content_delireverable_program_path(@chapter_content) 
    end
  end

  def new

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe

  end

  def create

    @delireverables_package.delireverables.each do |entregable|
      entregable.delireverable_users.create(file: params["delireverable_"+entregable.id.to_s ], user: current_user)
    end  
    redirect_to_next_content
  end
  def show

    #@comments = @question.comments.where(owner: current_user).order(created_at: :asc)
    ahoy.track "Viewed content", chapter_content_id: @chapter_content.id

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe

  end
  def edit

    add_breadcrumb @chapter_content.chapter.program.name, dashboard_program_path(@chapter_content.chapter.program)
    add_breadcrumb "<a class='active' href='#{dashboard_chapter_content_path(@chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end
  def update

    @delireverables_package.delireverables.each do |entregable|
      unless params["delireverable_"+entregable.id.to_s].nil?
        editable=entregable.delireverable_users.find_by(user: User.find(7))
        editable.update(file: params["delireverable_"+entregable.id.to_s])
      end
    end  
    redirect_to_next_content
  end  
  private
  def set_chapter_content
    @chapter_content = ChapterContent.find(params[:chapter_content_id])
  end
  def set_delireverables_package
    @delireverables_package=@chapter_content.model
  end

  def redirect_to_next_content
    program=@chapter_content.chapter.program
    mensaje= "Entregables guardados con éxito"
    if @chapter_content.lower_item
      redirect_to dashboard_chapter_content_path(@chapter_content.lower_item), notice: mensaje
    elsif program.next_chapter(@chapter_content.chapter) && program.next_chapter(@chapter_content.chapter).chapter_contents.first
      redirect_to dashboard_chapter_content_path(program.next_chapter(@chapter_content.chapter).chapter_contents.first), notice: mensaje
    else
      redirect_to dashboard_program_path(program), notice: mensaje
    end
  end  



end
