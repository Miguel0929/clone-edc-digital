class Dashboard::NotificationsController < ApplicationController
  def show
    notification = Notification.find(params[:id])
    path = case notification.notificable_type
      when 'CommentNotification'
        notification.update(read: true) unless notification.read

        dashboard_chapter_content_answer_path(notification.model.comment.answer.question.chapter_content, notification.model.comment.answer)
    end

    redirect_to path
  end
end
