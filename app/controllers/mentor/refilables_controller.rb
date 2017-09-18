class Mentor::RefilablesController < ApplicationController
  before_action :set_student
  before_action :set_refilable

  add_breadcrumb "EDCDIGITAL", :root_path
  before_action :set_user_breadcrum

  def show
    add_breadcrumb "<a class='active' href='#{mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def edit
    add_breadcrumb "<a class='active' href='#{edit_mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe
  end

  def update
    add_breadcrumb "<a class='active' href='#{edit_mentor_student_refilable_path(@user, @refilable)}'>#{@refilable.template_refilable.name}</a>".html_safe

    @refilable.update(refilable_params)
    respond_to do |format|
      format.html { redirect_to mentor_student_path(@user), notice: 'Rellenable actualizado'}
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

  def set_user_breadcrum
    if current_user.mentor?
      add_breadcrumb "#{@user.name}", mentor_student_path(@user)
    elsif current_user.admin?
      add_breadcrumb "#{@user.name}", user_path(@user)
    end  
  end
end
