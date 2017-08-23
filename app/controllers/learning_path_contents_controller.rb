class LearningPathContentsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_learning_path
	before_action :set_learning_path_content, except: [:sort, :create]
	add_breadcrumb "EDCDIGITAL", :root_path 
	def new
		@learning_path_content=@learning_path.learning_path_contents.new
	end
	def create
		@learning_path_content=@learning_path.learning_path_contents.new
		tipo=params[:tipo]
		content=params[:content]
		if tipo=="program"
			@learning_path_content.content_id= content
			@learning_path_content.content_type= "Program"
		elsif	tipo=="quiz"
			@learning_path_content.content_id= content
			@learning_path_content.content_type= "Quiz"
		elsif	tipo=="delireverable"
			@learning_path_content.content_id= content
			@learning_path_content.content_type= "Delireverable"
		elsif tipo=="refilables"
			@learning_path_content.content_id= content
			@learning_path_content.content_type= "TemplateRefilable"
		end
		if @learning_path_content.save
			render :json => {"contenido" => @learning_path_content}
		else
			render :json =>{"Error" => "No se pudo guardar"}
		end		
	end
	def destroy
		@learning_path_content.destroy
		redirect_to learning_path_path(@learning_path), notice: "Se eliminó exitosamente"	
	end
	def sort
		params[:content].each_with_index do |id, index|
      LearningPathContent.find(id).update_attributes({position: index + 1})
    end
    render nothing: true
	end	
	
	private
	def set_learning_path
		@learning_path=LearningPath.find(params[:learning_path_id])
	end
	def set_learning_path_content
		@learning_path_content=LearningPathContent.find(params[:id])
	end		
end
