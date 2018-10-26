class Reports
  extend MailTemplateHelper
  delegate :url_helpers, to: 'Rails.application.routes'

  def project_path
    url_helpers.project_path(self)
  end

  def self.report(report, root_url)

    cause = report.cause.to_s
    content_reported = root_url + "dashboard/course" + report.reportable_id.to_s
    email_report = report.user.email
    user_name = report.user.email
    id = report.user.id.to_s
    program = report.model.chapter.program.name
    chapter = report.model.chapter.name
    content = report.model.model.identifier

    template_title = "Reporte del contenido"
    template_name = "Hola administrador"
    template_message = "Hay un nuevo reporte de contenido. El usuario " + user_name + " (email: " + email_report + " , ID de usuario: " + id + ") ha reportado el contenido en la liga <a href=" + content_reported + ">" + content_reported + "</a>.<br><strong>Causa: </strong>" + cause + "<br><strong>Programa: </strong>" + program + "<br><strong>Capítulo: </strong>" + chapter + "<br><strong>Contenido: </strong>" + content + "<br>"
    template_footer = company_name_helper('Nuestro equipo')
    mail_recipient = mailer_support_helper
    mail_subject = "Contenido de plataforma reportado, ID: " + report.id.to_s

    send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)
  end

end	