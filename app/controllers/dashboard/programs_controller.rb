class Dashboard::ProgramsController < ApplicationController
  def index
    @programs = Program.all
  end

  def show
    @program = Program.find(params[:id])
  end

  def resume
    @program = Program.find(params[:id])
  end
end
