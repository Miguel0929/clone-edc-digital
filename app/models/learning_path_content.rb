class LearningPathContent < ActiveRecord::Base
  belongs_to :learning_path
  belongs_to :content, polymorphic: true

  def model
    content_type.constantize.find_by(id: content_id)
  end
end
