class Dashboard::NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb "EDC DIGITAL", :root_path
    add_breadcrumb "<a class='active' href='#{dashboard_notifications_path}'>Notificaciones</a>".html_safe

    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(30)
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
        elsif notification.model.evaluation?
          dashboard_evaluations_path(program_id: notification.model.program.id)
        elsif notification.model.more80?
          dashboard_program_path(notification.model.program)
        elsif notification.model.complete?  
          dashboard_learning_path_path              
        end
      when 'ReportNotification'
        notification.update(read: true) unless notification.read
        reports_path
      when 'LearningPathNotification'
        notification.update(read: true) unless notification.read
        dashboard_learning_path_path
      when 'SharedGroupAttachmentNotification'
        notification.update(read: true) unless notification.read
        dashboard_attachments_path
      when 'MentorProgramNotification'
        notification.update(read: true) unless notification.read
        if notification.model.more80?
          mentor_student_path(notification.model.user)
        elsif notification.model.complete?
          mentor_student_path(notification.model.user)
        end        
    end

    redirect_to path
  end

  def mark_as_read
    current_user.notifications.update_all(read: true)

    redirect_to dashboard_notifications_path
  end
end
