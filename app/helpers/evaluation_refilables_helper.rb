module EvaluationRefilablesHelper
	def user_promedio_refilable(total_obtenido, total_puntos)
		(total_obtenido*100)/total_puntos rescue 0
	end	
end
