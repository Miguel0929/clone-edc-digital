class CertificateTemplate < ActiveRecord::Base
  validates_presence_of :name, :file
  mount_uploader :file, TemplateFileUploader

  has_many :certificates#,  dependent: :destroy
end
