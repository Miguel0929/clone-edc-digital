class EvaluatorRefilables
  def self.for(user, evaluations)
    new(user, evaluations).evaluate
  end

  def initialize(user, evaluations)
    @user = user
    @evaluations = evaluations
  end

  def evaluate
    ActiveRecord::Base.transaction do
      @evaluations.each do |key, value|
        user_evaluation = UserEvaluationRefilable.find_or_initialize_by(user: @user, evaluation_refilable_id: value[:evaluation])
        user_evaluation.points = value[:points]
        user_evaluation.save!
      end
    end

    rescue ActiveRecord::RecordInvalid => exception
  end
end
