class GroupSerializer < ActiveModel::Serializer
  attributes *Group.column_names, :user_ids
end
