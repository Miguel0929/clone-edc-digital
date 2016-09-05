class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_program, only: [:show, :edit, :update, :destroy]

  def index
    @programs = Program.all
  end

  def show
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)

    if @program.save
      redirect_to @program
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @program.update(program_params)
      redirect_to @program
    else
      render :edit
    end
  end

  def destroy
     @program.destroy

     redirect_to programs_path
  end

  private
  def program_params
    params.require(:program).permit(:name)
  end

  def set_program
    @program = Program.find(params[:id])
  end
end
