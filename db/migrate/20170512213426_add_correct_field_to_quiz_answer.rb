class AddCorrectFieldToQuizAnswer < ActiveRecord::Migration
  def change
    add_column :quiz_answers, :correct, :boolean
  end
end
