class Dashboard::ProgramsController < ApplicationController
  before_action :authenticate_user!

  def index
    @programs = current_user.group.programs
  end

  def show
    @program = Program.find(params[:id])
  end

  def resume
    @program = Program.find(params[:id])
  end
end
