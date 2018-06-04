class CreateStudentEvaluateds < ActiveRecord::Migration
  def change
    create_table :student_evaluateds do |t|
    	t.integer :program_id, index: true
    	t.integer :total
    	t.integer :evaluados
    	t.integer :no_evaluados 
      t.timestamps null: false
    end
  end
end
