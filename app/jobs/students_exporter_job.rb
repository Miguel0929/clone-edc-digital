require 'csv'

class StudentsExporterJob
  include SuckerPunch::Job

  def perform(job_id, students, exporter)
    job = AsyncJob.find(job_id)
    
    progress = job.progress
    csv_string = CSV.generate(encoding: "UTF-8") do |csv|
      csv << ['Id', 'Nombre', 'Correo electrónico', 'Teléfono', 'Estado', 'Grupo', 'Porcentaje contestado', 'Porcentaje avance', 'Cursos inscritos']

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
        unless student.group.nil?
          student.group.programs.each do |program|
            csv << ["", "", "", "", "", "", "", "", "#{program.name}.", "Contestado: #{student.percentage_questions_answered_for(program)}%"]
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
