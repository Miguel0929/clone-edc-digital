class AnalyticsJob
  include EvaluationRefilablesHelper
  include SuckerPunch::Job
  workers 1

  def perform(program, groups, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    alumnos = 0; evaluados = 0; estudiantes = [];
    q_evaluados100_90 = 0; q_evaluados89_80 = 0; q_evaluados79_60 = 0; q_evaluados59_0 = 0 
    r_evaluados100_90 = 0; r_evaluados89_80 = 0; r_evaluados79_60 = 0; r_evaluados59_0 = 0 
    p_evaluados100_90 = 0; p_evaluados89_80 = 0; p_evaluados79_60 = 0; p_evaluados59_0 = 0  
    total_puntos_program = program.total_points
    
    groups.each do |group|
      programas_grupo = group.all_programs.pluck(:id) 
      if programas_grupo.include?(program.id)
        alumnos += group.students.invitation_accepted.where("user_seen > 0").count
        evaluados += group.students.invitation_accepted.where("user_seen > 0").joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id}).count
        #promedios
        estudiantes = group.students.invitation_accepted.where("user_seen > 0").joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id})
        estudiantes.each do |student|
          ##### Quizes ######
          quizzes = program.quizzes
          c_quizzes = program.quizzes.count
          total_quizzes = 0
          quizzes.each do |quiz|
            total_quizzes += quiz.promedio(student)
          end
          promedio_quizzes = total_quizzes / c_quizzes  rescue 0         
          if promedio_quizzes <= 100 && promedio_quizzes >= 90
            q_evaluados100_90 += 1
          elsif promedio_quizzes <= 89 && promedio_quizzes >= 80
            q_evaluados89_80 += 1
          elsif promedio_quizzes <= 79 && promedio_quizzes >= 60
            q_evaluados79_60 += 1
          elsif promedio_quizzes <= 59 && promedio_quizzes >= 0  
            q_evaluados59_0 += 1
          end
          ##### End Quizes ###### 

          ##### Refilables Programa #####
          template_refilables = program.template_refilables
          c_template_refilables = program.template_refilables.count
          
          total_template_refilables = 0
          template_refilables.each do |refilable|
            total_template_refilables += refilable.last_calification(student)
          end
          promedio_refil = total_template_refilables / c_template_refilables rescue 0 
       
          if promedio_refil <= 100 && promedio_refil >= 90
            r_evaluados100_90 += 1
          elsif promedio_refil <= 89 && promedio_refil >= 80
            r_evaluados89_80 += 1
          elsif promedio_refil <= 79 && promedio_refil >= 60
            r_evaluados79_60 += 1
          elsif promedio_refil <= 59 && promedio_refil >= 0  
            r_evaluados59_0 += 1
          end
          ##### End Refilable Programa #####

          ##### Preguntas Programa #####
          promedio_preguntas = program.evaluated_avg(student)
          if promedio_preguntas <= 100 && promedio_preguntas >= 90
            p_evaluados100_90 += 1
          elsif promedio_preguntas <= 89 && promedio_preguntas >= 80
            p_evaluados89_80 += 1
          elsif promedio_preguntas <= 79 && promedio_preguntas >= 60
            p_evaluados79_60 += 1
          elsif promedio_preguntas <= 59 && promedio_preguntas >= 0  
            p_evaluados59_0 += 1
          end
          ##### End Preguntas Programa ##### 
        end
        #end promedios
      end
    end
    job["progress"] += 1
    
    student_evaluated = StudentEvaluated.find_or_initialize_by(program_id: program.id)
    student_evaluated.total = alumnos; student_evaluated.evaluados = evaluados; student_evaluated.no_evaluados = alumnos - evaluados
    student_evaluated.save

    score_student_stat = ScoreStudentStat.find_or_initialize_by(program_id: program.id, tipo: 0)
    score_student_stat.rango1 = q_evaluados100_90; score_student_stat.rango2 = q_evaluados89_80; score_student_stat.rango3 = q_evaluados79_60; score_student_stat.rango4 = q_evaluados59_0
    score_student_stat.save

    score_student_stat = ScoreStudentStat.find_or_initialize_by(program_id: program.id, tipo: 1)
    score_student_stat.rango1 = r_evaluados100_90; score_student_stat.rango2 = r_evaluados89_80; score_student_stat.rango3 = r_evaluados79_60; score_student_stat.rango4 = r_evaluados59_0
    score_student_stat.save

    score_student_stat = ScoreStudentStat.find_or_initialize_by(program_id: program.id, tipo: 2)
    score_student_stat.rango1 = p_evaluados100_90; score_student_stat.rango2 = p_evaluados89_80; score_student_stat.rango3 = p_evaluados79_60; score_student_stat.rango4 = p_evaluados59_0
    score_student_stat.save
    
    redis.set(job_id, job.to_json)
  end
end   