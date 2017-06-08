class InvitationJob
  include SuckerPunch::Job

  def perform(name, email, group_id, url, job)

    user = User.invite!(:email => email, :first_name => name, group_id: group_id) do |u|
      u.skip_invitation = true
    end

      data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-confirmation_link-" => "#{url}?invitation_token=#{user.raw_invitation_token}"
            },
            subject: "Tu cuenta en EDCdigital ha sido creada"
          },
        ],
        from: {
          email: "soporte@edc-digital.com"
        },
        template_id: "506fcba3-80ce-4de9-bb7f-41e1e752ce0f"
      }

      progress = job.progress
      progress = progress + 1
      job.update({progress: progress})
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      begin
        response = sg.client.mail._("send").post(request_body: data)
        Rails.logger.info response.status_code
        Rails.logger.info response.body
        Rails.logger.info response.headers
        FakeEmail.new
      rescue Exception => e
        Rails.logger.info e.message
        FakeEmail.new
      end
  end
end