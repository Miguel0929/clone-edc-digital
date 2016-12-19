class CommentSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content

  has_one :user

  def created_at
    I18n.l(object.created_at, format: :special)
  end
end
