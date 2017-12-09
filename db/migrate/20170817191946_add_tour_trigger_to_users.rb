class AddTourTriggerToUsers < ActiveRecord::Migration
  def up
    add_column :users, :tour_trigger, :text, :default => {:first => true, :second => true, :third => true, :fourth => true, :fifth => true}.to_yaml
  end

  def down
    remove_column :users, :tour_trigger, :text
  end
end
