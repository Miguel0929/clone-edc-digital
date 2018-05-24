class CreateUserEvaluationRefilables < ActiveRecord::Migration
  def change
    create_table :user_evaluation_refilables do |t|
    	t.references :user, index: true, foreign_key: true
      t.references :evaluation_refilable, index: true, foreign_key: true
      t.integer :points	
      t.timestamps null: false
    end
  end
end
