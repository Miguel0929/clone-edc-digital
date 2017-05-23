class Mentor::ProgramsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_mentor
	add_breadcrumb "EDCDIGITAL", :root_path
	def index
    add_breadcrumb "<a class='active' href='#{mentor_programs_path}'>Programas</a>".html_safe
    @programs=[]
    current_user.groups.each do |g|
    	g.programs.each do |p|
    		unless @programs.include?(p)
    			@programs.push(p)	
    		end
    	end		
  	end
  end
  def show
    @program = Program.find(params[:id])
    rank= Rating.where(ratingable_type: "Program", ratingable_id: @program.id, user_id: current_user.id).first
    if rank.nil?
      @rank=0
    else
      @rank=rank.rank
    end 
    add_breadcrumb "Programas", :mentor_programs_path
    add_breadcrumb "<a class='active' href='#{mentor_program_path @program}'>#{@program.name}</a>".html_safe
  end  
end
