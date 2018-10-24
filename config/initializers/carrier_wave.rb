#if Rails.env.production?
#  CarrierWave.configure do |config|
#    config.fog_credentials = {
#      provider:           'Google',
#      google_storage_access_key_id: ENV['GOOGLE_STORAGE_ACCESS_KEY'],
#      google_storage_secret_access_key:  ENV['GOOGLE_STORAGE_SECRET'],
#      :persistent => false
#    }
#
#    config.fog_directory = ENV['GOOGLE_SEGMENT']
#  end
#end

#Usar la siguiente configuración para AMAZON WEB SERVICES AWS 3

if Rails.env.production?
    CarrierWave.configure do |config|
      config.fog_credentials = {
        :provider               => 'AWS',
        :aws_access_key_id      => ENV['AWS_ACCESS_KEY'],
        :aws_secret_access_key  => ENV['AWS_SECRET_KEY'],
        #:use_iam_profile        =>    true,	#Aparantemente esta línea no es necesaria https://github.com/markevans/dragonfly-s3_data_store/issues/22
        :region            => 'us-west-1'
      }
      config.fog_directory  = ENV['AWS_BUCKET']
      config.fog_public     = true
    end
end
