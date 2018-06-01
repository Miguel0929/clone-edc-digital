class AnalyticsJob
  include EvaluationRefilablesHelper
  include SuckerPunch::Job
  workers 1

  def perform(program, groups, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    alumnos = 0; evaluados = 0; evaluados100_90 = 0; evaluados89_80 = 0; evaluados79_60 = 0; evaluados59_0 = 0; estudiantes = [];  
    total_puntos_program = program.total_points
    
    groups.each do |group|
      programas_grupo = group.all_programs.pluck(:id) 
      if programas_grupo.include?(program.id)
        alumnos += group.students.count
        evaluados += group.students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id}).count
        #promedios
        estudiantes = group.students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id})
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
        #end promedios
      end
    end
    job["progress"] += 1
    job["total_alumnos_program"] << {program_id: program.id, program_name: program.name ,alumnos: alumnos, evaluados: evaluados, no_evaluados: alumnos - evaluados}
    job["total_alumnos_program_rango"] << {program_id: program.id, program_name: program.name ,total_100_90: evaluados100_90, total_89_80: evaluados89_80, total_79_60: evaluados79_60, total_59_0: evaluados59_0}     
    redis.set(job_id, job.to_json)
  end
end   