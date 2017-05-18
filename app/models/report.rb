class Report < ActiveRecord::Base
  belongs_to :reportable, polymorphic: true
  belongs_to :user

  def model
    reportable_type.constantize.find_by(id: reportable_id)
  end
end
