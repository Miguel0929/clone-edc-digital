class AddLearningPathToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :learning_path, index: true, foreign_key: true
  end
<<<<<<< HEAD
end
=======
end
>>>>>>> feature/avances-learning-path
