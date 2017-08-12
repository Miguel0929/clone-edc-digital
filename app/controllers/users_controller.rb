class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:students, :show, :change_evaluation]
  before_action :require_creator, only: [:students, :show]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :analytics_program, :analytics_quiz, :change_state]
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{users_path}'>Estudiantes</a>".html_safe
    ids=[]
    @users = User.students
    uni= Group.where.not(university_id: nil)
    uni.each do |u|
      unless ids.include?(u.university_id)
        ids.push(u.university_id)
      end
    end
    @universities=University.where(id: ids)
    if params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:group].present?
      @users = @users.where(group: params[:group])
    end

    if params[:university].present?
      @users = @users.joins(:group).where(groups: {university_id: params[:university]})
    end

    if params[:state].present?
      @users = @users.joins(:group).where(groups: {state_id: params[:state]})
    end

    if params[:tipo].present?
      @users = @users.joins(:group).where(groups: {category: params[:tipo]})
    end

    if params[:industria].present?
      @users = @users.where(industry_id: params[:industria])
    end

    ids=[]
    if params[:answered].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.answered_questions_percentage rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:answered].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_questions_answered_for(Program.find(params[:program])) rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end
    ids=[]
    if params[:visited].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.content_visited_percentage rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:visited].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_content_visited_for(Program.find(params[:program])) rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end

    @users = @users.page(params[:page]).per(100)

    respond_to do |format|
      format.html {}
      format.xls
    end
  end

  def show
    add_breadcrumb "Estudiantes", :students_users_path
    add_breadcrumb "<a class='active' href='#{user_path(@user)}'>#{@user.email}</a>".html_safe

    @delireverables = Delireverable.joins(delireverable_package: [:groups])
                                    .where('groups.id = ?', @user.group.id)
                                    .order(position: :asc) rescue []
  end

  def edit
    add_breadcrumb "Estudiantes", :students_users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_user_path(@user)}'>Editar información</a>".html_safe
  end

  def update
    add_breadcrumb "Estudiantes", :students_users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_user_path(@user)}'>Editar información</a>".html_safe

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "Se actualizó exitosamente el detalle del usuario #{@user.email}" }
        format.json { render json: @user, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy

    redirect_to  students_users_path, notice: "Se eliminó exitosamente al usuario #{@user.email}"
  end

  def analytics_program
    @program = Program.find(params[:program_id])
    @chapter_contents = ChapterContent.joins(chapter: [:program]).where('programs.id = ?', @program.id).order(position: :asc)

    add_breadcrumb "Estudiantes", :students_users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{analytics_program_user_path(@user, program_id: @program)}'>Detalles de programa</a>".html_safe
  end

  def analytics_quiz
    @quiz = Quiz.find(params[:quiz_id])
    add_breadcrumb "Estudiantes", :students_users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{analytics_quiz_user_path(@user, quiz_id: @quiz)}'>Detalles del exámen</a>".html_safe
  end

  def students
    add_breadcrumb "<a class='active' href='#{students_users_path}'>Estudiantes</a>".html_safe
    ids=[]
    @users = User.students.includes(:group)
    uni= Group.where.not(university_id: nil)
    uni.each do |u|
      unless ids.include?(u.university_id)
        ids.push(u.university_id)
      end
    end
    @universities=University.where(id: ids)

    if params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
          @allusers = User.students.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
          @allusers = User.students.where(invitation_accepted_at: nil)
      end
    end

    if params[:group].present? && params[:status].present?
      case params[:status]
        when 'active'
          @users = @users.where(group: params[:group]).where.not(invitation_accepted_at: nil)
          @allusers = User.students.where(group: params[:group]).where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(group: params[:group], invitation_accepted_at: nil)
          @allusers = User.students.where(group: params[:group], invitation_accepted_at: nil)
      end
      @group = Group.find(params[:group])
    elsif params[:group].present? && !params[:status].present?
      @users = @users.where(group: params[:group])
      @allusers = User.students.where(group: params[:group])
      @group = Group.find(params[:group])
    end

    if params[:university].present?
      @users = @users.joins(:group).where(groups: {university_id: params[:university]})
    end

    if params[:state].present?
      @users = @users.joins(:group).where(groups: {state_id: params[:state]})
    end

    if params[:tipo].present?
      @users = @users.joins(:group_).where(groups: {category: params[:tipo]})
    end

    if params[:industria].present?
      @users = @users.where(industry_id: params[:industria])
    end
    ids=[]
    if params[:answered].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.answered_questions_percentage rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:answered].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_questions_answered_for(Program.find(params[:program])) rescue 0
        if params[:answered].to_i >= percentage && params[:answered].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end
    ids=[]
    if params[:visited].present? && params[:program].length==0
      @users.each do |user|
        percentage = user.content_visited_percentage rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    elsif params[:visited].present? && params[:program].length > 0
      @users.each do |user|
        percentage = user.percentage_content_visited_for(Program.find(params[:program])) rescue 0
        if params[:visited].to_i >= percentage && params[:visited].to_i-10 < percentage
          ids.push(user.id)
        end
      end
      @users=@users.where(id: ids)
    end

    @users = @users.search_query(params[:query]) if params[:query].present? 

    respond_to do |format|
      format.html do
        @users = @users.page(params[:page]).per(100)
      end
      format.xls do
        fast = params[:fast] == 'true' ? true : false

        timestamp = Time.current.to_i
        redis = Redis.new
        redis.set("job_#{timestamp}", { total: @users.count, progress: 0 }.to_json)

        exporter = Exporter.new
        exporter.file = Pathname('public/system/export.csv').open
        exporter.save
        StudentsExporterJob.perform_async("job_#{timestamp}", @users, exporter, fast)
        redirect_to exporter_path(timestamp)
      end
      format.xlsx do
        fast = params[:fast] == 'true' ? true : false
        @users = User.students.includes(:group)

        timestamp = Time.current.to_i
        redis = Redis.new
        redis.set("job_#{timestamp}", { total: @users.count, progress: 0 }.to_json)

        exporter = Exporter.new
        exporter.file = Pathname('public/system/export.csv').open
        exporter.save
        StudentsExporterJob.perform_async("job_#{timestamp}", @users, exporter, fast)
        redirect_to exporter_path(timestamp)
      end
    end
  end

  def change_state
    if @user.banned?
      @user.unbann!
    else
      @user.bann!
    end

    redirect_to @user
  end

  def change_evaluation
    user = User.find(params[:user_id].to_i)
    if user.evaluation_status == "evaluado"
      to_nonevaluated = user.update(evaluation_status: "sin evaluar")
    else
      to_evaluated = user.update(evaluation_status: "evaluado")
    end
    render json: {eval: to_evaluated, not_eval: to_nonevaluated}
  end


  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :industry_id, :group_id, :role, :evaluation_status)
  end

  def validate_student
    redirect_to users_path unless @user.student?
  end

  def percentage_condition(percentage, count)
    case count
      when 10
        percentage >= 0 && percentage <=10
      when 20
        percentage >= 11 && percentage <=20
      when 30
        percentage >= 21 && percentage <=30
      when 40
        percentage >= 31 && percentage <=40
      when 50
        percentage >= 41 && percentage <=50
      when 60
        percentage >= 51 && percentage <=60
      when 70
        percentage >= 61 && percentage <=70
      when 80
        percentage >= 71 && percentage <=80
      when 90
        percentage >= 81 && percentage <=90
      when 100
        percentage >= 91 && percentage <=100
    end
  end
end
