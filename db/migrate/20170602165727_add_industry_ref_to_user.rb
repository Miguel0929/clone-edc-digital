class AddIndustryRefToUser < ActiveRecord::Migration
  def change
    add_reference :users, :industry, index: true, foreign_key: true
  end
end
