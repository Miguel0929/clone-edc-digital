class QueueNotification < ActiveRecord::Base

  enum category: [:new_chapter, :edit_chapter, :new_content, :edit_content]
  serialize :groups

end

#en detail se usarán tres opciones en forma de string: [up, down, edit] incluyendo si se trata de question, lesson o chapter, y el id de ese elemento (ej: up-question-124)