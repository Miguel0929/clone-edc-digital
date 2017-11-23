class InvitationJob
  include SuckerPunch::Job
  workers 1

  def perform(name, email, group_id, url, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    user = User.unscoped.find_by(email: email)
    if user.nil?
      job["new_records"] = job["new_records"] + 1;
      job["new_emails"] = job["new_emails"] << email

      user = User.invite!(:email => email, :first_name => name, group_id: group_id) do |u|
        u.skip_invitation = true
      end
    else
      if user.group_id != group_id.nil? && user.deleted_at.nil?
        user.update(group_id: group_id,)
        job["old_records_group"] = job["old_records_group"] + 1;
        job["old_emails_group"] = job["old_emails_group"] << email
      elsif user.deleted_at.nil?
        job["old_records"] = job["old_records"] + 1;
        job["old_emails"] = job["old_emails"] << email
      elsif user.deleted_at.nil? == false
          job["old_records_inactive"] = job["old_records_inactive"] + 1;
        job["old_emails_inactive"] = job["old_emails_inactive"] << email
      end

      user.invite! do |u|
        u.skip_invitation = true
      end
    end


      data = {
        personalizations: [
          {
            to: [ { email: user.email } ],
            substitutions: {
              "-confirmation_link-" => "#{url}?invitation_token=#{user.raw_invitation_token}"
            },
            subject: "Tu cuenta en EDC Digital ha sido creada"
          },
        ],
        from: {
          email: "soporte@edc-digital.com"
        },
        template_id: "506fcba3-80ce-4de9-bb7f-41e1e752ce0f"
      }

      job["progress"] = job["progress"] + 1;
      redis.set(job_id, job.to_json)

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
