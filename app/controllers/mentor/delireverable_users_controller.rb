class Mentor::DelireverableUsersController < ApplicationController
  before_action :set_student
  before_action :set_delireverable_user

  add_breadcrumb "EDC DIGITAL", :root_path
  add_breadcrumb "Estudiantes", :mentor_students_path

  def edit
    add_breadcrumb "<a href='#{mentor_student_path(@user)}'>#{@user.email}</a>".html_safe
    add_breadcrumb "<a class='active' href='#{edit_mentor_student_delireverable_user_path(@user, params[:id])}'>#{Delireverable.find(params[:id]).name}</a>".html_safe
  end

  def update
    respond_to do |format|
      if @delireverable_user.update(delireverable_user_params)
        format.html { redirect_to mentor_student_path(@user), notice: 'Entregable actualizado' }
        format.js { render "notification" }
        format.json { render json: @delireverable_user, status: :update }  
      else
        format.html { render :edit }
        format.json { render json: "Error", status: :unprocessable_entity }
      end
    end  
  end

  private
  def set_student
    @user = User.find(params[:student_id])
  end

  def set_delireverable_user
    @delireverable_user = DelireverableUser.find(params[:id])
  end

  def delireverable_user_params
    params.require(:delireverable_user).permit(:status, :comments)
  end
end
