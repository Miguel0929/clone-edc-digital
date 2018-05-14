class AddDescriptionToFrequentCategories < ActiveRecord::Migration
  def change
  	add_column :frequent_categories, :description, :string
  end
end
