module MailTemplateHelper
	require 'sendgrid-ruby'
	include SendGrid
	include ApplicationHelper
	require 'json'

	def send_mail_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject)

		company_name = company_name_helper
		company_mail = mailer_from_helper
		company_address = company_address_helper
		company_link = company_link_helper
		mail_message = IO.read(Rails.root + "app/views/generic_mailer_template/mail_template.txt") #Template tomado de aquí: https://github.com/derekpunsalan/responsive-email/blob/master/simple.html
		replacements = [["-template_title-", template_title], ["-template_name-", (template_name.empty? ? "Hola" : template_name)], 
										["-template_message-", template_message], 
										["-template_footer-", template_footer], ["-template_company_link-", company_link], ["-template_company_name-", company_name], 
										["-template_company_address-", company_address], ["-template_company_mail-", company_mail]]
		replacements.each {|replacement| mail_message.gsub!(replacement[0], replacement[1])}

		#Tomado del ejemplo completo que aparece aquí:
		#https://github.com/sendgrid/sendgrid-ruby/blob/master/examples/mail/mail.rb#L26

		string1 = 
			'{
				"content": [
				{
					"type": "text/html", 
					"value":
			'
		string2 = mail_message
		string3 = 
			'
				}
				], 
				"from": {
				"email":
			'
		string4 = '"' + company_mail + '",'
		string5 =
			'
				"name":
			'
		string6 = '"' + company_name + '"'
		string7 =
			'
				}, 
				"headers": {}, 
				"mail_settings": {
				"bypass_list_management": {
					"enable": true
				},
				"sandbox_mode": {
					"enable": false
				}, 
				"spam_check": {
					"enable": true, 
					"post_to_url": "http://example.com/compliance", 
					"threshold": 3
				}
				}, 
				"personalizations": [
				{
					"headers": {
					"X-Accept-Language": "es", 
					"X-Mailer": "MyApp"
					}, 
					"subject": 
			'
		string8 = '"' + mail_subject + '",'
		string9 =
			'
					"to": [
					{
						"email": 
			'
		string10 = '"' + mail_recipient + '"'
		string11 = 
			'
					}
					]
				}
				], 
				"subject":
			'
		string12 = '"' + mail_subject + '"'
		string13 =
			'
			}'

		data = JSON.parse(string1 + string2 + string3 + string4 + string5 + string6 + string7 + string8 + string9 + string10 + string11 + string12 + string13)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
    begin
      response = sg.client.mail._("send").post(request_body: data)
      Rails.logger.info response.status_code
      Rails.logger.info response.body
      Rails.logger.info response.headers
      FakeEmail.new
    rescue Exception => e
      Rails.logger.info e.message
      FakeEmail.new
    end

	end

end