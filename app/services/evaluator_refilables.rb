class EvaluatorRefilables

  def self.for(user, refilable, evaluations)
    new(user, refilable, evaluations).evaluate
  end

  def initialize(user, refilable, evaluations)
    @user = user
    @refilable = refilable
    @evaluations = evaluations
  end

  def evaluate
    ActiveRecord::Base.transaction do
      @evaluations.each do |key, value|
        user_evaluation = UserEvaluationRefilable.find_or_initialize_by(user: @user, refilable_id: @refilable, evaluation_refilable_id: value[:evaluation])
        user_evaluation.points = value[:points]
        user_evaluation.save!
      end
    end

    rescue ActiveRecord::RecordInvalid => exception
  end
end
