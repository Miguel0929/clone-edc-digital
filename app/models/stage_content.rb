class StageContent < ActiveRecord::Base
  belongs_to :stage
  belongs_to :coursable, polymorphic: true
  acts_as_list scope: :stage

  def model
    coursable_type.constantize.find(coursable_id)
  end
end
