class DelireverableMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delireverable, only: [:edit, :update, :destroy]
  before_action :require_admin
  
  add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path
  def create

    @delireverable = Delireverable.new(delireverable_params)

    if @delireverable.save
      redirect_to :back, notice: 'Entregable creado'
    end
  end

  def destroy
    @delireverable.destroy

    redirect_to :back, notice: 'Entregable eliminado'
  end
  def edit
    add_breadcrumb @delireverable.delireverable_package.chapter_content.chapter.program.name, program_path(@delireverable.delireverable_package.chapter_content.chapter.program) 
    add_breadcrumb "<a href='#{chapter_quiz_program_path(@delireverable.delireverable_package.chapter_content.chapter, @delireverable.delireverable_package.chapter_content)}'>#{@delireverable.delireverable_package.name}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{edit_delireverable_member_path(@delireverable)}'>#{@delireverable.name}</a>".html_safe

  end
  def update
    if @delireverable.update(delireverable_params)
      redirect_to chapter_delireverable_program_path(@delireverable.delireverable_package.chapter_content.chapter,@delireverable.delireverable_package.chapter_content), notice: 'Entregable actualizado'
    else
      render :new
    end
  end  

  private
  def delireverable_params
    params.require(:delireverable).permit(:name, :description, :file, :delireverable_package_id)
  end
  def set_delireverable
    @delireverable = Delireverable.find(params[:id])
  end
end
