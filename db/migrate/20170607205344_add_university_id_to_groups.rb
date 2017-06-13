class AddUniversityIdToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :university, index: true, foreign_key: true
  end
end
