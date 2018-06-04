class CreateScoreStudentStats < ActiveRecord::Migration
  def change
    create_table :score_student_stats do |t|
    	t.integer :program_id, index: true
    	t.integer :rango1
    	t.integer :rango2	
    	t.integer :rango3	
    	t.integer :rango4		
      t.timestamps null: false
    end
  end
end
