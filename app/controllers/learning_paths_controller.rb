class LearningPathsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_learning_path, only: [:show,:destroy]
	add_breadcrumb "EDCDIGITAL", :root_path
	def index
		add_breadcrumb "<a href='#{learning_paths_path}' class='active'>Rutas de aprendizaje</a>".html_safe
		@learning_path = LearningPath.all
	end
	def new
		add_breadcrumb "Ruta de aprendizaje", :learning_paths_path
    	add_breadcrumb '<a class="active">Nueva "Ruta de aprendizaje"</a>'.html_safe
		@programs = Program.ruta
	end

	def create
		@learning_path= LearningPath.new(name: params[:name])

		if @learning_path.save
			if params[:programs]
				programs=params[:programs]
				c=0
				programs.each do |program|
					c+=1
					LearningPathProgram.create(program_id: program,learning_path: @learning_path, position: c)
				end	
			end
			redirect_to learning_path_path(@learning_path), notice: "Se creó la ruta \"#{@learning_path.name}\" exitosamente"
		else
			render :new
		end					

	end
	def show
		add_breadcrumb "Rutas de aprendizaje", :learning_paths_path
    add_breadcrumb "<a class='active' href='#{learning_path_path(@learning_path)}'>#{@learning_path.name}</a>".html_safe
		@programs = Program.ruta
	end
	def destroy
		@learning_path.destroy
		redirect_to learning_paths_path, notice: "Se eliminó exitosamente"	
	end	

	private
		def set_learning_path
			@learning_path= LearningPath.find(params[:id])
		end
		def learning_path_params
	    params.permit(:name, programs: [])
		end	
end
