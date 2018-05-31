require 'csv'
require 'json'

class CoachesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_coach, only: [:destroy, :trainees]
  add_breadcrumb "EDC DIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ coaches_path }'>Tutores</a>".html_safe
    @coaches = User.where(role: 1, id: User.all.pluck(:coach_id).uniq)
    @coaches = @coaches.where("email ILIKE ? OR lower(first_name) = ? OR lower(last_name) = ?", params[:query].to_s + "%", params[:query].downcase, params[:query].downcase) if params[:query].present?
    @coaches = @coaches.page(params[:page]).per(50)
  end

  def trainees
    add_breadcrumb "<a href='#{ coaches_path }'>Tutores</a>".html_safe
    add_breadcrumb "<a class='active' href='#{ trainees_coach_path(@coach) }'>#{@coach.name}</a>".html_safe
    @trainees = @coach.trainees
    @trainees = @trainees.where("email ILIKE ? OR lower(first_name) = ? OR lower(last_name) = ?", params[:query].to_s + "%", params[:query].downcase, params[:query].downcase) if params[:query].present?
    @trainees = @trainees.page(params[:page]).per(20)
  end

  def new
    add_breadcrumb "<a href='#{ coaches_path }'>Tutores</a>".html_safe
    add_breadcrumb "<a class='active' href='#{ new_coach_path }'>Nuevos tutores</a>".html_safe
    @applicants = User.where(role: 1).where.not(invitation_accepted_at: nil)
    @trainees = User.where(role: 0, coach_id: nil).where.not(invitation_accepted_at: nil)
    @trainees = User.where(role: 0).where.not(invitation_accepted_at: nil)
  end

  def create
    new_coach = User.find(params[:nominee_id])
    trainees = User.where(id: params[:trainees_ids])
    invalid_trainees = []
    trainees.each do |trainee|
      if trainee.coach.nil?
        trainee.coach = new_coach # sets trainee.couch_id
        trainee.save
        ut = UserTrainee.create(user_id: params[:nominee_id], trainee_id: trainee.id) # creates usertrainee record
      else
        invalid_trainees.push(trainee)
      end
    end
    message = invalid_trainees.empty? ? "La tutoría fue creado con éxito" : "Tutoría creada con éxito, #{invalid_trainees.count} de #{trainees.count} estudiantes ya contaban con tutor"
    flash[:notice] = message
    redirect_to coaches_path
  end

  def batch_deletion
    coach = User.find(params[:id])
    trainees = coach.trainees
    uts = UserTrainee.where(user_id: coach.id, trainee_id: trainees.pluck(:id))
    uts.destroy_all
    trainees.each do |trainee|
      trainee.update(coach_id: nil)
    end
    flash[:notice] = "Tutorías eliminadas"
    redirect_to coaches_path
  end

  def destroy
    trainees = @coach.trainees
    uts = UserTrainee.where(user_id: @coach.id)
    trainees.each do |trainee|
      trainee.update(coach_id: nil)
    end
    uts.destroy_all
    flash[:notice] = "Tutoría eliminada exitosamente"
    redirect_to coaches_path
  end  

  def uploading_status
    redis = Redis.new
    job = JSON.parse(redis.get("job_" + params[:job_id].to_s)) unless redis.get("job_" + params[:job_id].to_s).nil?
    puts redis.get("job_" + params[:job_id].to_s)
    if job.nil?
      output = {total: 0, progress: 0, nonexistent_coaches: ["Error, petición no encontrada"], nonexistent_trainees: ["Error, petición no encontrada"], invalid_coaching: ["Error, petición no encontrada"] }
    else 
      output = job
    end
    respond_to do |format|
      format.json {render json: output}
    end
  end

  def post_csv
    total = CSV.read(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8').size
    timestamp = params[:timestamp]
    redis = Redis.new
    redis.set("job_#{timestamp}", {
      total: total,
      progress: 0,
      nonexistent_coaches: [],
      nonexistent_trainees: [],
      invalid_coaching: [],
    }.to_json)

    redis2 = Redis.new
    job = JSON.parse(redis2.get("job_" + timestamp.to_s)) unless redis2.get("job_" + timestamp.to_s).nil?

    CSV.foreach(params[:csv].tempfile, headers: true, encoding:'iso-8859-1:utf-8') do |row|
      UploadCoachJob.perform_async(row['TUTOR'], row['APRENDIZ'], "job_#{timestamp}")
    end
    output = {message: "Se completó la tarea de generación de tutorías"}
    respond_to do |format|
      format.json {render json: output}
    end
  end

  private
  def set_coach
    @coach = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:nominee_id, trainees_ids: [])
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end
end
