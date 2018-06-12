class ProgramAttachment < ActiveRecord::Base
	belongs_to :program
	enum document_type: [:image, :pdf, :office, :other_document]
	validates_presence_of :file
	mount_uploader :file, ProgramAttachmentUploader

	def self.document_type_options
    [['Selecciona un tipo de documento', 'none'], ['Fotografía o Imagen', 'image'], ['PDF', 'pdf'], ['Documento Office', 'office'], ['Otro', 'other_document']]
  end

  def humanize_document_type
    option = self.class.document_type_options.select { |option| option.include? document_type }.flatten
    option.empty? ? nil : option[0]
  end

  def display_name
    File.basename(file.url)
  end
end
