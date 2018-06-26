class ConversationsController < ApplicationController
  before_action :authenticate_user!

  add_breadcrumb "EDC DIGITAL", :root_path

  def new
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{}'>Nuevo mensaje</a>".html_safe
    if current_user.mentor? || current_user.profesor?
      ids=[]
      @contacts=[]
      @groups = current_user.groups
      @groups.each do |g|
        ids.push(g.id)
        g.active_students.each do |s|
          @contacts.push(s)
        end  
      end
      @contacts = @contacts.push(current_user.trainees).flatten.uniq
    end
    if current_user.student?
      @contacts=current_user.group.users.collect
    end
    if current_user.admin?
      @contacts=User.mentors.collect
    end  
  end
  def show
    @receipts = conversation.receipts_for(current_user).order(:created_at)
    conversation.mark_as_read(current_user)
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{conversation_path}'>#{@receipts.first.message.subject}</a>".html_safe
  end
  def create
    if current_user.mentor? || current_user.profesor?
      recipients = (User.where(id: conversation_params[:loner_recipients]) + User.where(group_id: conversation_params[:group_recipients], role: 0).where.not(invitation_accepted_at: nil)).uniq
    else
      recipients = User.where(id: conversation_params[:recipients])
    end
    if conversation_params[:attachment].nil?
      conversation = current_user.send_message(recipients,conversation_params[:body],conversation_params[:subject]).conversation
      auto_ticket(conversation)
      ######
        #if current_user.mentor? || current_user.profesor?
        #  puts "ay wey create"
        #  puts conversation
        #  puts conversation.class
        #  conversation.recipients.where(receiver_id: current_user.id, is_delivered: false) do |recipient|
        #    recipient.update(is_delivered: true)
        #  end
        #end
      ######
    else
      conversation = current_user.send_message(recipients,conversation_params[:body],conversation_params[:subject]).conversation
      att = MailboxAttachment.new
      att.message_id = conversation.receipts.where(mailbox_type: 'sentbox',receiver_id: current_user.id).last.message.id
      att.file = conversation_params[:attachment]
      att.save!
    end  
    flash[:success] = "Tu mensaje ha sido enviado"
    redirect_to conversation_path(conversation)
  end
  def reply
    if message_params[:attachment].nil?
      current_user.reply_to_conversation(conversation, message_params[:body])
      auto_ticket(conversation)

      if message_params[:close_ticket] == 'true'
        close_ticket(conversation)
      end
      ######
        #if current_user.mentor? || current_user.profesor?
        #  puts "ay wey reply"
        #  puts conversation
        #  puts conversation.class
        #  conversation.receipts.where(receiver_id: current_user.id, is_delivered: false) do |recipient|
        #    recipient.update(is_delivered: true)
        #  end
        #end
      ######
    else
      current_user.reply_to_conversation(conversation,message_params[:body])
      att= MailboxAttachment.new
      att.message_id= conversation.receipts.where(mailbox_type: 'sentbox',receiver_id: current_user.id).last.message.id
      att.file=message_params[:attachment]
      att.save!
    end  
    flash[:notice] = "Your reply message was succesfully"
    redirect_to conversation_path(conversation)
  end 

  def trash
    conversation.move_to_trash(current_user)
    redirect_to mailbox_inbox_path
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to mailbox_inbox_path
  end   

  def print_members
    originator = conversation.originator
    participants = conversation.participants
    recipients = participants - [originator]
    
    output = { recipients: recipients.map(&:email).join(", "), originator: originator.nil? ? "Usuario eliminado" : originator.email , recipientsCount:  recipients.count.to_s}
    respond_to do |format|
      format.json {render json: output}
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:subject, :body, :attachment, :recipients, :loner_recipients => [], :group_recipients => [])
  end 

  def message_params
    params.require(:message).permit(:subject, :body, :attachment, :close_ticket,)
  end 

  def auto_ticket(conversation)
    if current_user.student? && !current_user.coach.nil? && conversation.participants.count == 2
      if conversation.participants.map{|p| p.id}.include?(current_user.coach.id)
        prev_ticket = Ticket.find_by(element_id: conversation.id, coach_id: current_user.coach.id, trainee_id: current_user.id, category: 0)
        if prev_ticket.nil?
          title = "Nuevo mensaje de alumno: " + (conversation.subject)
          ticket = Ticket.new(element_id: conversation.id, coach_id: current_user.coach.id, trainee_id: current_user.id, category: 0, title: title, closed: false)
          ticket.save
        else
          title = "Han respondido tu mensaje: " + (conversation.subject)
          prev_ticket.update(closed: false, title: title)
        end
      end
    end
  end

  def close_ticket(conversation)
    to_close = Ticket.find_by(element_id: conversation.id, category: 0)
    if !to_close.nil? then to_close.update(closed: true) end
  end

end
