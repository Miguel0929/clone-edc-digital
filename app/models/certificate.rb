class Certificate < ActiveRecord::Base
  belongs_to :certificate_template

  validates_presence_of :name, :certificate_template_id, :batch, :date, :program, :route

  mount_uploader :file, CertificateFileUploader
  #mount_uploader :dropbox_file, CertificateFileUploaderDropbox

  enum mailing_status: [:na, :sent, :unsent, :no_mail]

  def to_hash
    {
      id: self.id,
      name: self.name,
      email: self.email,
      file_url: self.file.url,
      created_at: self.created_at
    }
  end
end
