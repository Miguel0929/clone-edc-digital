class Report < ActiveRecord::Base
  belongs_to :reportable, polymorphic: true

  def model
    reportable_type.constantize.find_by(id: reportable_id)
  end
end
