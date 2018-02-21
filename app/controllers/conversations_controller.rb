class ConversationsController < ApplicationController
  before_action :authenticate_user!

  add_breadcrumb "EDC DIGITAL", :root_path

  def new
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{}'>Nuevo mensaje</a>".html_safe
    if current_user.mentor? || current_user.profesor?
      ids=[]
      @contacts=[]
      groups=current_user.groups
      groups.each do |g|
        ids.push(g.id)
        g.active_students.each do |s|
          @contacts.push(s)
        end  
      end
    end
    if current_user.student?
      @contacts=current_user.group.users.collect
    end
    if current_user.admin?
      @contacts=User.mentors.collect
    end  
  end
  def show
    @receipts= conversation.receipts_for(current_user).order(:created_at)
    conversation.mark_as_read(current_user)
    add_breadcrumb "<a href='#{mailbox_inbox_path}'>Mensajes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{conversation_path}'>#{@receipts.first.message.subject}</a>".html_safe
  end
  def create
    recipients=User.where(id: conversation_params[:recipients])
    if conversation_params[:attachment].nil?
      conversation = current_user.send_message(recipients,conversation_params[:body],conversation_params[:subject]).conversation
    else
      conversation=current_user.send_message(recipients,conversation_params[:body],conversation_params[:subject]).conversation
      att= MailboxAttachment.new
      att.message_id= conversation.receipts.where(mailbox_type: 'sentbox',receiver_id: current_user.id).last.message.id
      att.file=conversation_params[:attachment]
      att.save!
    end  
    flash[:success] = "Tu mensaje a sido enviado!"
    redirect_to conversation_path(conversation)
  end
  def reply
    if message_params[:attachment].nil?
      current_user.reply_to_conversation(conversation,message_params[:body])
    else
      current_user.reply_to_conversation(conversation,message_params[:body])
      att= MailboxAttachment.new
      att.message_id= conversation.receipts.where(mailbox_type: 'sentbox',receiver_id: current_user.id).last.message.id
      att.file=message_params[:attachment]
      att.save!
    end  
    flash[:notice]="Your reply message was succesfully"
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

  private

  def conversation_params
    params.require(:conversation).permit(:subject, :body, :attachment, :recipients)
  end 

  def message_params
    params.require(:message).permit(:subject,:body, :attachment)
  end 
end
