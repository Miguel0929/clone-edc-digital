class ApplicationMailer < ActionMailer::Base
  extend MailTemplateHelper
  
  default from: mailer_from_helper('')
  layout 'mailer'
end
