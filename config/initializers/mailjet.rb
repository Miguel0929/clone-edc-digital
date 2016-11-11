Mailjet.configure do |config|
  config.api_key = ENV['MAILER_USERNAME']
  config.secret_key = ENV['MAILER_PASSWORD']
  config.default_from = 'hola@emprendiendodesdecero.com'
end
