class AddTipoToLearningPath < ActiveRecord::Migration
  def change
    add_column :learning_paths, :tipo, :integer
  end
end
