class CreateStudentEvaluatedPointsStates < ActiveRecord::Migration
  def change
    create_table :student_evaluated_points_states do |t|
      t.integer :program_id, index: true
      t.integer :state_id, index: true  
      t.integer :tipo, index: true 
      t.integer :puntaje_90_100
      t.integer :puntaje_80_89
      t.integer :puntaje_60_79
      t.integer :puntaje_0_59
      t.timestamps null: false
    end
  end
end
