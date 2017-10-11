class AddTipoToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :tipo, :integer
  end
end
