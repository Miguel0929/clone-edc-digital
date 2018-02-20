class Profesor::RefilablesController < ApplicationController
	before_action :set_student
  before_action :set_refilable

  add_breadcrumb "EDC DIGITAL", :root_path
 

  def show
  	add_breadcrumb "#{@user.name}", profesor_student_path(@user)
    add_breadcrumb "<a href='#{dashboard_template_refilables_path(user_id: @user.id)}'>Plantillas</a>".html_safe
    add_breadcrumb "<a class='active' href='#{mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def edit
    add_breadcrumb "<a class='active' href='#{edit_profesor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def update
    add_breadcrumb "<a class='active' href='#{edit_mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe

    @refilable.update(refilable_params)
    respond_to do |format|
      format.html { redirect_to profesor_student_path(@user), notice: 'Plantilla actualizada'}
      format.js { render "notification"}
      format.json { render json: @refilable, status: :update }
    end  
  end

  private
  def set_student
    @user = User.find(params[:student_id])
  end

  def set_refilable
    @refilable = Refilable.find(params[:id])
  end

  def refilable_params
    params.require(:refilable).permit(:comments)
  end
end
