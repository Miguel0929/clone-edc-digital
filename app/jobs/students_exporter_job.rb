require 'csv'

class StudentsExporterJob
  include SuckerPunch::Job

  def perform(job_id, students, exporter, fast)
    job = AsyncJob.find(job_id)
    
    progress = job.progress
    csv_string = CSV.generate(encoding: "UTF-8") do |csv|
      if fast
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance']
      else
        header = ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance']
        Program.all.each do |program|
          header << "#{program.name} CONTESTADO:"
          header << "#{program.name} VISTO:"
        end
      end
      csv << header

      students.each do |student|
        progress = progress + 1
        content = [
          student.id,
          student.name,
          student.email,
          student.phone_number,
          student.status,
          student.group.nil? ? "" : student.group.name,
          "#{student.answered_questions_percentage}%",
          "#{student.content_visited_percentage}%",
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
        job.update({progress: progress})
      end
    end
    File.open('public/system/export.csv', 'w'){ |f| f.write(csv_string) }
    exporter.file = Pathname('public/system/export.csv').open
    exporter.save
    File.open('public/system/export.csv', 'w'){ |f| f.write('') }
    job.destroy
  end
end
