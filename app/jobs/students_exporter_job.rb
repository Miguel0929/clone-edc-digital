require 'csv'

class StudentsExporterJob
  include SuckerPunch::Job

  def perform(job_id, students, exporter, fast)
    job = AsyncJob.find(job_id)
    
    progress = job.progress
    csv_string = CSV.generate(encoding: "UTF-8") do |csv|
      if fast
        csv << ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance']
      else
        csv << ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', 'Programas inscrito']
      end

      students.each do |student|
        progress = progress + 1
        csv << [
          student.id,
          student.name,
          student.email,
          student.phone_number,
          student.status,
          student.group.nil? ? "" : student.group.name,
          "#{student.answered_questions_percentage}%",
          "#{student.content_visited_percentage}%",
          "",
          ""
        ]

        if !fast
          unless student.group.nil?
            Program.all.each do |program|
              if student.group.programs.exists?(program)
                csv << ["", "", "", "", "", "", "", "", 
                  "#{program.name}.", 
                  "Contestado: #{student.percentage_questions_answered_for(program)}%",
                  "Visto: #{student.content_visted_for(program)}%"
                ]
              else
                csv << ["","","","","","","","","#{program.name}.", "N/A", "N/A"]
              end
            end
          end
        end

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
