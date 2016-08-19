class AddRubricToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :rubric_id, :integer, index: true
  end
end
