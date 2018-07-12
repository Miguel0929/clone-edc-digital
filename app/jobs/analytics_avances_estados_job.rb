class AnalyticsAvancesEstadosJob
  include EvaluationRefilablesHelper
  include SuckerPunch::Job
  workers 1

  def perform(program, groups, state, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    alumnos = 0; evaluados = 0
    
    groups.each do |group|
      programas_grupo = group.all_programs.pluck(:id) 
      if programas_grupo.include?(program.id)
        alumnos += group.students.invitation_accepted.where("user_seen > 0").count
        evaluados += group.students.invitation_accepted.where("user_seen > 0").joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id}).count
=begin        
        estudiantes = group.students.invitation_accepted.where("user_seen > 0").joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id})
        estudiantes.each do |student|
          obtenidos = program.points_earned(student)
          promedio = user_promedio_refilable(obtenidos, total_puntos_program)
          if promedio <= 100 && promedio >= 90
            evaluados100_90 += 1
          elsif promedio <= 89 && promedio >= 80
            evaluados89_80 += 1
          elsif promedio <= 79 && promedio >= 60
            evaluados79_60 += 1
          elsif promedio <= 59 && promedio >= 0  
            evaluados59_0 += 1
          end  
        end
=end
      end
    end
    
    student_evaluated = StudentEvaluatedState.find_or_initialize_by(program_id: program.id, state_id: state.id)
    student_evaluated.total = alumnos; student_evaluated.evaluados = evaluados; student_evaluated.no_evaluados = alumnos - evaluados
    student_evaluated.save



    job["progress"] += 1
   
    redis.set(job_id, job.to_json)
  end
end   