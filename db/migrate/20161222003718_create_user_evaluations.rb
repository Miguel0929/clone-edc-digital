class CreateUserEvaluations < ActiveRecord::Migration
  def change
    create_table :user_evaluations do |t|
      t.references :user
      t.references :evaluation
      t.integer :points
    end
  end
end
