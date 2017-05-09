class SharedAttachment < ActiveRecord::Base
  enum document_type: [:image, :pdf, :office, :other_document]

  belongs_to :user
  belongs_to :owner, foreign_key: 'owner_id', class_name: 'User'
  mount_uploader :file, SharedFileUploader

  validates_presence_of :file

  before_save :rename_file

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

  private
  def rename_file
    self.file = self.file
  end
end
