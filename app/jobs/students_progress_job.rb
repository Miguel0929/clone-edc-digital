class StudentsProgressJob
  include SuckerPunch::Job

  def perform(job_id)
    job = AsyncJob.find(job_id)
    
    #puts "ah cabron"
    progress = job.progress
    groups = Group.all

    groups.each do |group|
      programs = group.all_programs
      students = group.students.all
      programs.each do |program|
        students.each do |student|
          progress = progress + 1
          
          if student.status == 'Activo'
            student_progress = student.answered_questions_percentage
            student_seen = student.content_visited_percentage
            student.update(user_progress: student_progress, user_seen: student_seen)
            prog_progress =  student.percentage_questions_answered_for(program)
            prog_seen =  student.percentage_content_visited_for(program)
            stat = ProgramStat.where(program_id: program.id, user_id: student.id).last
            if stat != nil
              stat.update(program_progress: prog_progress, program_seen: prog_seen)
            else
              new_stat = ProgramStat.create(program_id: program.id, user_id: student.id, program_progress: prog_progress, program_seen: prog_seen)
            end
          end

          job.update({progress: progress})
        end
      end
    end

    #puts "ay wey"
    #puts ProgramStat.all.count

    job.destroy
  end
end
