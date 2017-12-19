class AddSenderToMentorHelps < ActiveRecord::Migration
  def up
    add_column :mentor_helps, :sender, :integer
  end

  def down
    remove_column :mentor_helps, :sender, :integer
  end
end
