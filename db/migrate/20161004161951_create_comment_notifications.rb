class CreateCommentNotifications < ActiveRecord::Migration
  def change
    create_table :comment_notifications do |t|
      t.integer :comment_id, index: true
      t.integer :user_id, index: true
    end
  end
end
