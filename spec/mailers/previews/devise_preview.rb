class DevisePreview < ActionMailer::Preview
  def invitation_instructions
    Devise::Mailer.invitation_instructions(User.first, 'token')
  end
end

