require 'csv'

class StudentsExporterJob
  include SuckerPunch::Job
  workers 1

  def perform(job_id, students, exporter, fast)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?


    csv_string = CSV.generate(encoding: "UTF-8") do |csv|
      if fast
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Status', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', "Codigo activación"]
      else
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Status', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', "Codigo activación", "Estado", "Universidad", "Sector económico", "Género", "Edad", "Situación actual", "Tema de interés", "Mi mayor reto será", "Lo que busco en la plataforma", "Biografía"]
        Program.all.each do |program|
          header << "#{program.name} CONTESTADO"
          header << "#{program.name} VISTO"
        end
      end
      csv << header

      students.each do |student|
        content = [
          student.id,
          student.name,
          student.email,
          student.phone_number,
          student.status,
          student.group.nil? ? "n/a" : student.group.name,
          "#{student.user_progress.ceil}%",
          "#{student.user_seen.ceil}%",
          student.user_code.nil? ? "----------------" : student.user_code.codigo,
          student.state,
          student.group.nil? || student.group.university.nil? ? "n/a" : student.group.university.name,
          student.industry.nil? ? "n/a" : student.industry.name,
        ]
        programs = ''
        if !fast
          
          if student.user_detail.nil?
            [student.gender_output, "n/a", "n/a", "n/a", "n/a", "n/a", "n/a"].each do |data|
              content << data
            end
          else
            [student.gender_output, student.age, student.user_detail.situation, student.user_detail.interest, student.user_detail.challenge, student.user_detail.goal, student.bio].each do |data|
              content << data
            end
          end

          unless student.group.nil?
            Program.all.each do |program|
              if student.group.all_programs.exists?(program)
                content << "#{student.integral_percentage_progress_for(program).ceil}%"
                content << "#{student.integral_percentage_visited_for(program).ceil}%"
              else
                content << "n/a"
                content << "n/a"
              end
            end
          end
        end
        csv << content
        job["progress"] = job["progress"] + 1;
        redis.set(job_id, job.to_json)
      end
    end
    File.open('public/system/export.csv', 'w'){ |f| f.write(csv_string) }
    exporter.file = Pathname('public/system/export.csv').open
    exporter.save
    File.open('public/system/export.csv', 'w'){ |f| f.write('') }
  end
end
