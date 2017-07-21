class Mentor::RefilablesController < ApplicationController
  before_action :set_student
  before_action :set_refilable

  def show
  end

  def edit
  end

  def update
    @refilable.update(refilable_params)

    redirect_to mentor_student_path(@user), notice: 'Rellenable actualizado'
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
