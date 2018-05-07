class LearningPathContentsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_learning_path
	before_action :set_learning_path_content, except: [:sort, :create]
	after_action :update_program_sequences

	def new
		@learning_path_content=@learning_path.learning_path_contents.new
	end
	def create
		p params
		existe = true
		maximo = 0
		if learning_path_contents_params[:tipo] == "program"
			if @learning_path.learning_path_contents.where(content_type: "Program", content_id: params[:content]).first.nil?
				maximo = @learning_path.learning_path_contents.where(content_type: "Program").maximum(:position) rescue 0
				if maximo.nil? then maximo = 0 end
				@learning_path_content=@learning_path.learning_path_contents.new(content_type: "Program", content_id: params[:content], position: maximo+1)
			else
				existe = false
			end
		elsif learning_path_contents_params[:tipo] == "quiz"
			if @learning_path.learning_path_contents.where(content_type: "Quiz", content_id: params[:content]).first.nil?
				maximo = @learning_path.learning_path_contents.where(content_type: "Quiz").maximum(:position) rescue 0
				if maximo.nil? then maximo = 0 end
				@learning_path_content=@learning_path.learning_path_contents.new(content_type: "Quiz", content_id: params[:content], position: maximo+1)
			else
				existe = false
			end
		elsif learning_path_contents_params[:tipo] == "refilable"
			if @learning_path.learning_path_contents.where(content_type: "TemplateRefilable", content_id: params[:content]).first.nil?	
				maximo = @learning_path.learning_path_contents.where(content_type: "TemplateRefilable").maximum(:position) rescue 0
				if maximo.nil? then maximo = 0 end
				@learning_path_content=@learning_path.learning_path_contents.new(content_type: "TemplateRefilable", content_id: params[:content], position: maximo+1)
			else
				existe = false
			end
		elsif learning_path_contents_params[:tipo] == "delireverable"
			if @learning_path.learning_path_contents.where(content_type: "DelireverablePackage", content_id: params[:content]).first.nil?		
				maximo = @learning_path.learning_path_contents.where(content_type: "DelireverablePackage").maximum(:position) rescue 0
				if maximo.nil? then maximo = 0 end
				@learning_path_content=@learning_path.learning_path_contents.new(content_type: "DelireverablePackage", content_id: params[:content], position: maximo+1)	
			else
				existe = false
			end
		end
		if existe	
			if @learning_path_content.save
				render :json => {"contenido" => @learning_path_content, "poly_content"=> @learning_path_content.model, "error" => "No"}
			else
				render :json =>{"error" => "No se pudo guardar"}
			end
		else
			render :json =>{"error" => "Existe"}
		end			
	end

	def sort
		params[:content].each_with_index do |id, index|
    		LearningPathContent.find(id).update_attributes({position: index + 1})
	    end
	    render nothing: true
	end	
	def destroy
		@learning_path_content.destroy
		redirect_to learning_path_path(@learning_path), notice: "Se eliminó exitosamente"	
	end

	private
	def set_learning_path
		@learning_path=LearningPath.find(params[:learning_path_id])
	end
	def set_learning_path_content
		@learning_path_content=LearningPathContent.find(params[:id])
	end
	def learning_path_contents_params
    	params.permit(:tipo, :content)
  	end	
  	def update_program_sequences
  		if @learning_path.tipo == "fisica"
  			groups =  Group.where(learning_path_id: @learning_path.id)
  		elsif @learning_path.tipo == "moral"
  			groups =  Group.where(learning_path2_id: @learning_path.id)
  		end
  		UpdateProgramSequenceJob.perform_async(groups)
  	end
end
