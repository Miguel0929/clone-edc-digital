class DelireverableUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :delireverable

  enum status: [:sent, :reviewed]

  mount_uploader :file, DelireverableUserFileUploader

  validates_presence_of :file

  def huminize_status
    case status
    when 'sent'
      'Enviado'
    when 'reviewed'
      'Revisado'
    end
  end
end
