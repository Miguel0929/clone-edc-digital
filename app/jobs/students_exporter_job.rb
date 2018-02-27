require 'csv'

class StudentsExporterJob
  include SuckerPunch::Job
  workers 1

  def perform(job_id, students, exporter, fast)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?


    csv_string = CSV.generate(encoding: "UTF-8") do |csv|
      if fast
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', "Codigo activación"]
      else
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', "fhdkjfhdsj"]
        Program.all.each do |program|
          header << "#{program.name} CONTESTADO:"
          header << "#{program.name} VISTO:"
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
          student.group.nil? ? "" : student.group.name,
          "#{student.answered_questions_percentage}%",
          "#{student.content_visited_percentage}%",
          student.user_code.nil? ? "----------------" : student.user_code.codigo,
        ]
        programs = ''
        if !fast
          unless student.group.nil?
            Program.all.each do |program|
              if student.group.programs.exists?(program)
                content << "#{student.percentage_questions_answered_for(program)}%"
                content << "#{student.content_visted_for(program)}%"
              else
                content << "N/A"
                content << "N/A"
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
