class AnalyticsMentorStateJob
  include EvaluationRefilablesHelper
  include SuckerPunch::Job
  workers 1

  def perform(mentor, states, job_id)
    redis = Redis.new
    job = JSON.parse(redis.get(job_id)) unless redis.get(job_id).nil?
    
    states.each do |state|
      ssc = StudentsStatesCoach.find_or_initialize_by(state_id: state.id, coach_id: mentor.id, active: true)
      ssc.total = mentor.linked_students_state(state)
      ssc.save
    end  
  
    job["progress"] += 1
    
    redis.set(job_id, job.to_json)
  end
end   