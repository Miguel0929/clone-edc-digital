class AnalyticsStateFunnelMentorJob
  include SuckerPunch::Job
  workers 1

  def perform(program, mentor, state, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?
    q_evaluados100_90 = 0; q_evaluados89_80 = 0; q_evaluados79_60 = 0; q_evaluados59_0 = 0
    p_evaluados100_90 = 0; p_evaluados89_80 = 0; p_evaluados79_60 = 0; p_evaluados59_0 = 0
    r_evaluados100_90 = 0; r_evaluados89_80 = 0; r_evaluados79_60 = 0; r_evaluados59_0 = 0
    
    q_program = program.quizzes.count; r_program = program.template_refilables.count; p_program = program.questions?
    
    students = mentor.trainees.invitation_accepted.joins(:group).where("groups.state_id = ? and users.user_seen > 0", state.id)
    students = students.joins(:program_stats).where(:program_stats => {checked: 1, program_id: program.id})
    students.each do |student|
      programas_grupo = student.group.all_programs.pluck(:id) 
      if programas_grupo.include?(program.id)
        if q_program > 0
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
        end

        if r_program > 0
          ##### Refilables #####
          template_refilables = program.template_refilables
          c_template_refilables = 0
          
          total_template_refilables = 0
          template_refilables.each do |refilable|
            if refilable.evaluation_refilables.count > 0
              c_template_refilables += 1
              total_template_refilables += refilable.last_calification(student)
            end  
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
        end

        if p_program
          ##### Preguntas #####
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
        end
      end      
    end  
 
    if q_program > 0
      student_puntaje_quiz = StudentEvaluatedPointsStateMentor.find_or_initialize_by(program_id: program.id, state_id: state.id, tipo: 0, mentor_id: mentor.id)
      student_puntaje_quiz.puntaje_90_100 = q_evaluados100_90; student_puntaje_quiz.puntaje_80_89 = q_evaluados89_80; student_puntaje_quiz.puntaje_60_79 = q_evaluados79_60; student_puntaje_quiz.puntaje_0_59 = q_evaluados59_0;
      student_puntaje_quiz.save
    end
    if r_program > 0
      student_puntaje_refi = StudentEvaluatedPointsStateMentor.find_or_initialize_by(program_id: program.id, state_id: state.id, tipo: 1, mentor_id: mentor.id)
      student_puntaje_refi.puntaje_90_100 = r_evaluados100_90; student_puntaje_refi.puntaje_80_89 = r_evaluados89_80; student_puntaje_refi.puntaje_60_79 = r_evaluados79_60; student_puntaje_refi.puntaje_0_59 = r_evaluados59_0;
      student_puntaje_refi.save
    end
    if p_program
      student_puntaje_prog = StudentEvaluatedPointsStateMentor.find_or_initialize_by(program_id: program.id, state_id: state.id, tipo: 2, mentor_id: mentor.id)
      student_puntaje_prog.puntaje_90_100 = p_evaluados100_90; student_puntaje_prog.puntaje_80_89 = p_evaluados89_80; student_puntaje_prog.puntaje_60_79 = p_evaluados79_60; student_puntaje_prog.puntaje_0_59 = p_evaluados59_0;
      student_puntaje_prog.save
    end    
    job["progress"] += 1
   
    redis.set(job_id, job.to_json)
  end
end   