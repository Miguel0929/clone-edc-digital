class ChapterSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :created_at, :updated_at

  has_many :chapter_contents
end
