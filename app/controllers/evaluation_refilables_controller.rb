class EvaluationRefilablesController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin
	before_action :set_template_refilable
	before_action :set_evaluation, only: [:update, :destroy]

	def create	
		max = @template.evaluation_refilables.count + 1
		@evaluation = @template.evaluation_refilables.build(name: params_evaluations[:name], points: params_evaluations[:points], excelent: params_evaluations[:excelent], good: params_evaluations[:good], regular: params_evaluations[:regular], bad: params_evaluations[:bad], position: max)	
		respond_to do |format|
			if @evaluation.save
				format.js{}
			end
		end  
	end
	
	def update
		respond_to do |format|
			if @evaluation.update(params_evaluations)
				format.js{}
			end
		end  
	end

	def destroy
		e = @evaluation
		@evaluation.destroy
		redirect_to :back, notice: "Se eliminó exitosamente la rúbrica #{e.name}"
	end

	def sort
		params[:rubric].each_with_index do |id, index|
      EvaluationRefilable.find(id).update_attributes({position: index + 1})
    end

    render nothing: true
	end	

	private
	def set_template_refilable
		@template = TemplateRefilable.find(params[:template_refilable_id])
	end	

	def set_evaluation
		@evaluation = EvaluationRefilable.find(params[:id])
	end

	def params_evaluations
		params.permit(:name, :points, :excelent, :good, :regular, :bad)
	end
end
