CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_credentials = {
      provider:           'Rackspace',
      rackspace_username: ENV['rackspace_username'],
      rackspace_api_key:  ENV['rackspace_api_key'],
      rackspace_region:   :iad,  # optional, defaults to :dfw
      rackspace_temp_url_key: ENV['rackspace_temp_url_key']#'ciecicapacitacion'
    }

    config.fog_directory = ENV['rackspace_fog_directory']
    config.fog_public = true
  end
end
