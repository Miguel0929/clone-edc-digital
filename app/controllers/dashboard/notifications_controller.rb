class Dashboard::NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb "EDCDIGITAL", :root_path
    add_breadcrumb "<a class='active' href='#{dashboard_notifications_path}'>Notificaciones</a>".html_safe

    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def show
    notification = Notification.find(params[:id])

    path = case notification.notificable_type
      when 'CommentNotification'
        notification.update(read: true) unless notification.read
        if current_user.mentor?
          mentor_question_path(notification.model.comment.question, user_id: notification.model.comment.owner_id)
        else
          router_dashboard_chapter_content_answers_path(notification.model.comment.question.chapter_content)
        end
      when 'ProgramNotification'
        notification.update(read: true) unless notification.read

        if notification.model.rubric?
          resume_dashboard_program_path(notification.model.program)
        elsif notification.model.new_content?
          dashboard_program_path(notification.model.program)
        elsif notification.model.new_program?
          dashboard_programs_path
        end
    end

    redirect_to path
  end

  def mark_as_read
    current_user.notifications.update_all(read: true)

    redirect_to dashboard_notifications_path
  end
end
