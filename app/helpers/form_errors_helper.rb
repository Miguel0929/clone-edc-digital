module FormErrorsHelper
  def class_for(object, attribute)
    object.errors[attribute].empty? ? '' : 'has-error'
  end

  def error_for(object, attribute)
    content_tag(:label, object.errors[attribute].first , class: ['error']) unless object.errors[attribute].empty?
  end
end
