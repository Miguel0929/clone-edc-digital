class AddEvaluationStatusFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :evaluation_status, :integer, default: 0
  end
end
