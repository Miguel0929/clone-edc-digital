class AddRefilableToUserEvaluationRefilables < ActiveRecord::Migration
  def change
    add_reference :user_evaluation_refilables, :refilable, index: true, foreign_key: true
  end
end
