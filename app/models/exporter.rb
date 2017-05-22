class Exporter < ActiveRecord::Base
  mount_uploader :file, ExporterUploader
end
