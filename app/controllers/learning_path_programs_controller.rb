class LearningPathProgramsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_learning_path
	before_action :set_learning_path_program, except: [:sort, :create]
	add_breadcrumb "EDCDIGITAL", :root_path 
	def new
		@learning_path_content=@learning_path.learning_path_contents.new
	end
	def create
		maximo=@learning_path.learning_path_programs.maximum(:position)
		@learning_path_program=@learning_path.learning_path_programs.new(program_id: params[:program], position: maximo+1)
		if @learning_path_program.save
			render :json => {"contenido" => @learning_path_program, "programa"=> @learning_path_program.program}
		else
			render :json =>{"Error" => "No se pudo guardar"}
		end
					
	end
	def destroy
		@learning_path_program.destroy
		redirect_to learning_path_path(@learning_path), notice: "Se eliminó exitosamente"	
	end
	def sort
		params[:content].each_with_index do |id, index|
      		LearningPathProgram.find(id).update_attributes({position: index + 1})
    	end
    	render nothing: true
	end	
	
	private
	def set_learning_path
		@learning_path=LearningPath.find(params[:learning_path_id])
	end
	def set_learning_path_program
		@learning_path_program=LearningPathProgram.find(params[:id])
	end		
end
