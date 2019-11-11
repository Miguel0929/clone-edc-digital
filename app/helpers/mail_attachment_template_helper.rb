module MailAttachmentTemplateHelper
	require 'sendgrid-ruby'
	include SendGrid
	require 'json'
	require 'base64'

	def send_mail_attachment_template(template_title, template_name, template_message, template_footer, mail_recipient, mail_subject, certificate)

		company_name = company_name_helper('')
		company_mail = mailer_from_helper('')
		company_address = company_address_helper('')
		company_link = company_link_helper('')
		mail_message = IO.read(Rails.root + "app/views/generic_mailer_template/mail_template.txt") #Template tomado de aquí: https://github.com/derekpunsalan/responsive-email/blob/master/simple.html
		replacements = [["-template_title-", template_title], ["-template_name-", (template_name.empty? ? "Hola" : template_name)], 
										["-template_message-", template_message], 
										["-template_footer-", template_footer], ["-template_company_link-", company_link], ["-template_company_name-", company_name], 
										["-template_company_address-", company_address], ["-template_company_mail-", company_mail]]
		replacements.each {|replacement| mail_message.gsub!(replacement[0], replacement[1])}

		encoded_attachment = Base64.strict_encode64(File.open(certificate.file.file.file, "rb").read)

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
		string12 = '"' + mail_subject + '",'
		string13 = 
			'
				"attachments": [
				{
				"content": "' + encoded_attachment + '", 
				"content_id": "ii_139db99fdb5c3704", 
				"disposition": "inline", 
				"filename": "certificadocurso.pdf", 
				"name": "certificadocurso", 
				"type": "pdf"
				}
				]
			'
		string14 =
			'
			}'

		data = JSON.parse(string1 + string2 + string3 + string4 + string5 + string6 + string7 + string8 + string9 + string10 + string11 + string12 + string13 + string14)
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

	def company_name_helper(nil_replacement)
		result = ENV['COMPANY_NAME']
		if result.nil?
			result = nil_replacement
		end
		result.dup.force_encoding(Encoding::UTF_8)
	end

	def mailer_from_helper(nil_replacement)
		result = ENV['MAILER_FROM']
		if result.nil?
			result = nil_replacement
		end
		result.dup.force_encoding(Encoding::UTF_8)
	end

	def company_address_helper(nil_replacement)
		result = ENV['COMPANY_ADDRESS']
		if result.nil?
			result = nil_replacement
		end
		result.dup.force_encoding(Encoding::UTF_8)
	end

	def company_link_helper(nil_replacement)
		result = ENV['COMPANY_LINK']
		if result.nil?
			result = nil_replacement
		end
		result.dup.force_encoding(Encoding::UTF_8)
	end

	def mailer_support_helper
		result = ENV['MAILER_SUPPORT']
		if result.nil?
			result = 'ruben@onestartup.mx'
		end
		result.dup.force_encoding(Encoding::UTF_8)
	end

end
