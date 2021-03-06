class EvaluatorRefilables

  def self.for(user, refilable, evaluations, mentor)
    new(user, refilable, evaluations, mentor).evaluate
  end

  def initialize(user, refilable, evaluations, mentor)
    @user = user
    @refilable = refilable
    @evaluations = evaluations
    @mentor = mentor
  end

  def evaluate
    ActiveRecord::Base.transaction do
      points = []
      @evaluations.each do |key, value|
        #user_evaluation = UserEvaluationRefilable.find_or_initialize_by(user: @user, refilable_id: @refilable, evaluation_refilable_id: value[:evaluation])
        #puts "mamar"
        #puts ["user", @user.id]
        #puts ["evaluation_refilable_id", value[:evaluation]]
        #puts ["refilable", @refilable]
        #puts ["mentor", @mentor]
        evals = UserEvaluationRefilable.where(user: @user, evaluation_refilable_id: value[:evaluation])
        if evals.count > 1
          user_evaluation = evals.order(:created_at).last
        else
          user_evaluation = UserEvaluationRefilable.find_or_initialize_by(user: @user, evaluation_refilable_id: value[:evaluation])
        end
        user_evaluation.points = value[:points]
        user_evaluation.refilable_id = @refilable # NUEVO
        if user_evaluation.save!
          points.push(user_evaluation.puntaje)
        end
      end
      refilable = Refilable.find(@refilable)
      total_points = refilable.template_refilable.evaluation_refilables.pluck(:points).inject(0){|sum,x| sum + x }
      result = (points.inject(0){|sum,x| sum + x } * 100) / total_points rescue 0
      refilable.update(points: result, mentor_id: @mentor)
    end

    rescue ActiveRecord::RecordInvalid => exception
  end



end
