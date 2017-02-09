class CommentsBelongsToQuestions < ActiveRecord::Migration
  def up
    add_column :comments, :question_id, :integer, index: true
    add_column :comments, :owner_id, :integer, index: true

    Comment.includes(answer: [:user]).all.each do |comment|
      comment.update(question: comment.answer.question, owner: comment.answer.user) unless comment.answer.nil?
    end
  end

  def down
    remove_column :comments, :question_id, :integer, index: true
    remove_column :comments, :owner_id, :integer, index: true
  end
end
