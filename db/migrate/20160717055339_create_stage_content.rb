class CreateStageContent < ActiveRecord::Migration
  def change
    create_table :stage_contents do |t|
      t.integer :stage_id
      t.integer :coursable_id
      t.string  :coursable_type
    end
  end
end
