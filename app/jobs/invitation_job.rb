class InvitationJob
  include SuckerPunch::Job
  workers 1

  def perform(name, email, group_id, url, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    u = User.find_by(email: email)
    if u.nil?
      job["new_records"] = job["new_records"] + 1;
      job["new_emails"] = job["new_emails"] << email
    else
      u.update(group_id: group_id)
      job["old_records"] = job["old_records"] + 1;
      job["old_emails"] = job["old_emails"] << email
    end

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

      job["progress"] = job["progress"] + 1;
      redis.set(job_id, job.to_json)

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
