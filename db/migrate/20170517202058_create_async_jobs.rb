class CreateAsyncJobs < ActiveRecord::Migration
  def change
    create_table :async_jobs do |t|
      t.string :title
      t.integer :progress
      t.integer :total

      t.timestamps null: false
    end
  end
end
