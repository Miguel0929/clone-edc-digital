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
		@programs = Program.all
		@quizzes = Quiz.all
		@templates_refilables = TemplateRefilable.all
		@delireverable_packages = DelireverablePackage.all
	end

	def create
		@learning_path= LearningPath.new(name: params[:name])

		if @learning_path.save
			if learning_path_params[:programs]
				programs=learning_path_params[:programs]
				c=0
				programs.each do |program|
					c+=1
					@learning_path.learning_path_contents.create(content_id: program, content_type: "Program",position: c)
				end	
			end
			if learning_path_params[:quizzes]
				quizzes=learning_path_params[:quizzes]
				c=0
				quizzes.each do |quiz|
					c+=1
					@learning_path.learning_path_contents.create(content_id: quiz, content_type: "Quiz",position: c)
				end	
			end
			if learning_path_params[:refilables]
				refilables=learning_path_params[:refilables]
				c=0
				refilables.each do |refilable|
					c+=1
					@learning_path.learning_path_contents.create(content_id: refilable, content_type: "TemplateRefilable",position: c)
				end	
			end
			if learning_path_params[:delireverables]
				delireverables=learning_path_params[:delireverables]
				c=0
				delireverables.each do |delireverable|
					c+=1
					@learning_path.learning_path_contents.create(content_id: delireverable, content_type: "DelireverablePackage",position: c)
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
		@programs = Program.all
		@quizzes = Quiz.all
		@templates_refilables = TemplateRefilable.all
		@delireverable_packages = DelireverablePackage.all
		@c_programs = @learning_path.learning_path_contents.where(content_type: "Program").order(:position)
		@c_quizzes = @learning_path.learning_path_contents.where(content_type: "Quiz").order(:position)
		@c_refilables = @learning_path.learning_path_contents.where(content_type: "TemplateRefilable").order(:position)
		@c_delireverables= @learning_path.learning_path_contents.where(content_type: "DelireverablePackage").order(:position)
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
	    params.permit(:name, programs: [], quizzes: [], refilables: [], delireverables: [])
		end	
end
