class ChapterContentSerializer < ActiveModel::Serializer
  attributes :id, :coursable_id, :coursable_type

  has_one :coursable
end
