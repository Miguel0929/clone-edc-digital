class AddProgramToQuiz < ActiveRecord::Migration
  def change
    add_reference :quizzes, :program, index: true, foreign_key: true
  end
end
