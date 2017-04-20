module MailboxHelper
  def unread_messages_count
    mailbox.inbox(:read=>false).count()
  end
end
