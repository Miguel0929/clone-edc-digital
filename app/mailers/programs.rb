class Programs
  extend MailTemplateHelper

	def self.new_program(program, user, ruta)

    template_title = "Nuevo programa para ti"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Un nuevo programa ha sido añadido para ti. El programa <strong>" + program.name + "</strong> ahora esta diponible.</p><p><a href='" + ruta + "'>Visita este enlace para ver el programa >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "El nuevo programa ha sido añadido para ti"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
	end

	def self.up_program(program, user, ruta)

    template_title = "Programa actualizado"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "El programa <strong>" + program.name + "</strong> tiene nuevo contenido diponible para ti.</p><p><a href='" + ruta + "'>Visita este enlace para ver el contenido >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Se ha actualizado tu programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
	end

  def self.up_rubric(program, user, ruta)

    template_title = "Rúbrica de evaluación actualizada"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Tu rúbrica de evaluación en el programa <strong>" + program.name + "</strong> ha sido actualizada recientemente.</p><p><a href='" + ruta + "'>Visita este enlace para ver el programa >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Se ha actualizado tu rúbrica de evaluación"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.up_evaluation(program, user, ruta)

    template_title = "Programa evaluado"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Has sido evaluado en el programa <strong>" + program.name + "</strong>.</p><p><a href='" + ruta + "'>Visita este enlace para ver el programa >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Ha sido evaluado en el programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.more95_mentor(program, user, student, ruta)

    template_title = "Tu alumno está cerca de terminar un programa"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "El alumno " + student.name + " está a punto de concluir el programa <strong>" + program.name + "</strong>, te invitamos a que revises sus avances y completes la rúbrica de evaluación correspondiente.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "El alumno " + student.name + " está a punto de terminar el programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.more95_student(program, user, ruta)

    template_title = "Cerca de terminar un programa"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Estás a punto de terminar el programa <strong>" + program.name + "</strong>.</p><p><a href='" + ruta + "'>Visita este enlace para ver el programa >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Estás a punto de terminar el programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.complete_mentor(program, user, student, ruta)

    template_title = "Tu alumno ha terminado un programa"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "El alumno " + student.name + " ha terminado el programa <strong>" + program.name + "</strong>, te invitamos a que revises sus avances y completes la rúbrica de evaluación correspondiente.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "El alumno " + student.name + " ha terminado el programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.complete_student(program, user, ruta)

    template_title = "Terminaste un programa"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "Has terminado el programa <strong>" + program.name + "</strong>.</p><p><a href='" + ruta + "'>Visita este enlace para ver el programa >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "Has terminado el programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end 

  def self.key_question(program, user, student, ruta)

    template_title = "Tu alumno contestó una pregunta clave"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "El alumno " + student.name + " ha contestado una pregunta clave del programa <strong>" + program.name + "</strong>, te invitamos a que revises sus avances y completes la rúbrica de evaluación correspondiente.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "El alumno " + student.name + " ha contestado una pregunta clave del programa " + program.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end	

  def self.answered_refilable(program, template_refilable, soporte2, student, ruta)

    template_title = "Tu alumno contestó una plantilla"
    template_name = (user.first_name.nil? ? "Hola" : user.name)
    template_message = "El alumno " + student.name + " ha contestado la plantilla <strong>" + template_refilable.name + "</strong> del programa <strong>" + (program.nil? ? "Plantilla sin programa" : program.name) + "</strong>, te invitamos a que revises sus avances.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = user.email
    mail_subject = "El alumno " + student.name + " ha contestado la plantilla " + template_refilable.name

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

  def self.update_question(chapter_content, mentor, student, ruta)

    template_title = "Tu alumno corrigió una respuesta"
    template_name = (mentor.first_name.nil? ? "Hola" : mentor.name)
    template_message = "El alumno " + student.name + " ha corregido un respuesta de programa, te invitamos a que revises sus avances.</p><p><a href='" + ruta + "'>Visita este enlace para revisar avances >></a></p><p>Estamos para servirte, que tengas un excelente día."
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = mentor.email
    mail_subject = "El alumno " + student.name + " ha corregido una respuesta de programa"

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end 

end	