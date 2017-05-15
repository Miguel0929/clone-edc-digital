class AddAnswerTextToQuizAnswer < ActiveRecord::Migration
  def change
    add_column :quiz_answers, :answer_text, :text
  end
end
