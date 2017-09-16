class ProgramSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at, :updated_at :content_type, :cover_url, :tipo

  has_many :chapters

  def cover_url
    object.cover.url
  end
end
