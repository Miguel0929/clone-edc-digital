class ReportNotification < ActiveRecord::Base
  belongs_to :report
  has_many :notification, as: :notificable 
end
