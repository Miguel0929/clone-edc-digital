class Delireverable< ActiveRecord::Base
  belongs_to :delireverable_package
  
  acts_as_list scope: :delireverable_package

  validates_presence_of :name, :description, :file
  mount_uploader :file, DelireverableFileUploader
end
