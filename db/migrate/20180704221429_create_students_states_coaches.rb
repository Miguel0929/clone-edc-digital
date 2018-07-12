class CreateStudentsStatesCoaches < ActiveRecord::Migration
  def change
    create_table :students_states_coaches do |t|
    	t.integer :state_id, index: true
    	t.integer :coach_id, index: true
    	t.integer :total
    	t.boolean :active
      t.timestamps null: false
    end
  end
end
