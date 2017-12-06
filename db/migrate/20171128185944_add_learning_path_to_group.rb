class AddLearningPathToGroup < ActiveRecord::Migration
  def change
  	add_reference :groups, :learning_path2, references: :learning_path, index: true
  end
end
