class AddSupportTextAndValuePointsToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :support_text, :string
    add_column :questions, :points, :integer
  end
end
