class LearningPathsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_learning_path, only: [:show, :edit, :update, :destroy]
	add_breadcrumb "EDCDIGITAL", :root_path
	def index
		add_breadcrumb "<a href='#{learning_paths_path}' class='active'>Rutas de aprendizaje</a>".html_safe
		@learning_path = LearningPath.all
	end
	def new
		add_breadcrumb "Ruta de aprendizaje", :learning_paths_path
    	add_breadcrumb '<a class="active">Nueva "Ruta de aprendizaje"</a>'.html_safe
		@programs = Program.ruta
		@quizes= Quiz.all
		@delireverables=Delireverable.all
    @refilables = TemplateRefilable.all
	end

	def create
		@learning_path= LearningPath.new(name: params[:name])


		if @learning_path.save
			if params[:programs]
				programs=params[:programs]
				programs.each do |program|
					LearningPathContent.create(content: Program.find(program),learning_path: @learning_path)
				end	
			end

			if params[:quizes]
				quizes=params[:quizes]
				quizes.each do |quiz|
					LearningPathContent.create(content: Quiz.find(quiz),learning_path: @learning_path)
				end	
			end

			if params[:delireverables]
				delireverables=params[:delireverables]
				delireverables.each do |delireverable|
					LearningPathContent.create(content: Delireverable.find(delireverable),learning_path: @learning_path)
				end	
			end

			if params[:refilables]
				refilables=params[:refilables]
				refilables.each do |refilables|
					LearningPathContent.create(content: TemplateRefilable.find(refilables),learning_path: @learning_path)
				end	
			end
			redirect_to learning_path_path(@learning_path), notice: "Se creó la ruta \"#{@learning_path.name}\" exitosamente"
		else
			render :new
		end					

	end
	def show
		@programs = Program.ruta
		@quizes= Quiz.all
		@delireverables=Delireverable.all
    	@refilables = TemplateRefilable.all
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
	    params.permit(:name,programs: [], quizes:[], deliverables:[], refilables:[])
		end	
end
