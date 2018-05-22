class MailboxController < ApplicationController
  before_action :authenticate_user!  
  helper_method :recipient_name
  
  add_breadcrumb "EDC DIGITAL", :root_path

  def inbox
    add_breadcrumb "<a class='active' href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    @inbox = mailbox.inbox.page(params[:page]).per(20)
    @active = :inbox
  end

  def sent
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{mailbox_sent_path}'>Mensajes enviados</a>".html_safe
    @sent = mailbox.sentbox.page(params[:page]).per(20)
    @active = :sent
  end

  def trash
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{mailbox_trash_path}'>Mensajes eliminados</a>".html_safe
    @trash = mailbox.trash.page(params[:page]).per(20)
    @active = :trash
  end

  def recipient_name(conversation)
    filtered_participants = conversation.participants.reject do |u| 
      u.id == current_user.id
    end 
    if filtered_participants.count > 1
      if filtered_participants.count <= 3
        names = ""
        filtered_participants.map{|user| names = names + user.first_name + ", " }
        2.times do names.chop! end
        names
      else
        groups = []
        filtered_participants.map{|user| groups << user.group}
        if (groups.uniq.count == 0 || groups.uniq.count > 1)
          "Múltiples participantes"
        elsif groups.uniq.count == 1
          groups.first.name
        end
      end
    else
      filtered_participants.first.name.to_s
    end
  end

  def show_recipients(conversation)
    filtered_participants = conversation.participants.reject do |u| 
      u.id == current_user.id
    end
    recipients_names = []
    filtered_participants.map{|user| recipients_names << user.name}
  end

end
