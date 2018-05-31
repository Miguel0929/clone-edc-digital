class UploadCoachJob
  include SuckerPunch::Job
  workers 1

  def perform(coach_id, trainee_id, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?

    coach = User.find(coach_id.to_i)
    trainee = User.find(trainee_id.to_i)

    if coach.nil?
      job["nonexistent_coaches"] = job["nonexistent_coaches"] << coach_id
    elsif trainee.nil?
      job["nonexistent_trainees"] = job["nonexistent_trainees"] << coach_id
    else
      if trainee.coach.nil?
        trainee.coach = coach # sets trainee.couch_id
        trainee.save
        ut = UserTrainee.create(user_id: coach.id, trainee_id: trainee.id) # creates usertrainee record
      else
        job["invalid_coaching"] = job["invalid_coaching"] << trainee.email
      end
    end

    job["progress"] = job["progress"] + 1
    redis.set(job_id, job.to_json)

  end

end