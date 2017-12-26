class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:students, :show, :change_evaluation]
  before_action :require_creator, only: [:students, :show]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :analytics_program, :analytics_quiz, :change_state, :summary, :learning_path, :program_permitted]
  before_action :set_program, only:[:program_permitted]
  add_breadcrumb "EDCDIGITAL", :root_path
  helper_method :get_program_active

  helper_method :last_moved_program
  helper_method :last_visited_content
  helper_method :permiso_programs

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

                                   
    @programs = @user.group.all_programs rescue []
                                   
    @delireverables = @user.group.all_delireverables rescue []
                                 
    @refilables = @user.group.all_refilables rescue []
                                
    @quizzes = @user.group.all_quizzes rescue []                              
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

  def get_program_active(user, program)
    ProgramActive.where(user_id: user.id, program_id: program.id).first
  end

  def summary
    add_breadcrumb "<a href='#{students_users_path}'>Estudiantes</a>".html_safe
    add_breadcrumb "<a class='active' href='#{summary_user_path(@user)}'>Resumen: #{@user.email}</a>".html_safe
    quizzes_results = @user.answered_quizzes
    @quizzes_average = quizzes_results[0]
    @answered_quizzes = quizzes_results[1]
    @total_quizzes = @user.total_quizzes
    @delireverables = Delireverable.joins(delireverable_package: [:groups]).where('groups.id = ?', @user.group.id).count
    @refilables = TemplateRefilable.joins(:groups).where('groups.id = ?', @user.group.id).count
    @complete_delireverables = DelireverableUser.where(user: @user).count
    @complete_refilables = Refilable.where(user: @user).count
    @self_archives = @user.attachments.count
    @shared_archives = @user.shared_attachments.count
    @sent_chats = Mailboxer::Message.where(sender_id: @user).count
    @mentor_messages = MentorHelp.where(sender: @user.id).count
    @result_exams = @answered_quizzes.to_f / @total_quizzes.to_f * 100
    @result_delireverables = @complete_delireverables.to_f / @delireverables.to_f * 100
    @result_refilables = @complete_refilables.to_f / @refilables.to_f * 100
  end

  def learning_path
    @programs_fisica=@user.group.learning_path.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c=0
    @c1=0
    ids=[]
    unless @programs_fisica.nil?
      @programs_fisica.each do |p|
        c+=1
        anterior = p.anterior(@user.group.learning_path)
        if @user.percentage_questions_answered_for(anterior) >= 95 || c==1 || (@user.percentage_content_visited_for(anterior) == 100 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      @programs_fisica=LearningPathContent.where(id: ids).order(:position)
    end

    @programs_moral=@user.group.learning_path2.learning_path_contents.where(content_type: "Program").order(:position) rescue nil
    c=0
    @c2=0
    ids=[]
    unless @programs_moral.nil?
      @programs_moral.each do |p|
        c+=1
        anterior = p.anterior(@user.group.learning_path2)
        if @user.percentage_questions_answered_for(anterior) >= 95 || c==1 || (@user.percentage_content_visited_for(anterior) == 100 && anterior.questions? == false)
          ids.push(p.id)
        else
          break
        end
      end
      @programs_moral=LearningPathContent.where(id: ids).order(:position)
    end
    #end
    @modal_trigger = @user.video_trigger
    @tour_trigger = @user.tour_trigger

  end

  def program_permitted
    if permiso_programs(@program,@user)
      redirect_to learning_path_user_path(@user), alert: "El curso \"#{@program.name}\" no esta disponible para el alumno #{@user.name}"
    else
      redirect_to learning_path_user_path(@user), notice: "El curso \"#{@program.name}\" si esta disponible para el alumno  #{@user.name}" 
    end  
  end  

  private
  def set_user
    @user = User.find(params[:id])
  end
  def set_program
     @program= Program.find(params[:program_id])
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

  def last_visited_content(program, stats)
    if stats != nil
      last = ( !stats.last_content.nil? ? stats.last_content : nil)
      return last
    else
      return nil
    end
  end

  def last_moved_program(program)
     last_moved_content = program.get_last_move(current_user)
    if !last_moved_content.nil?
      last_move = last_moved_content.chapter_content_id
      last_time = last_moved_content.updated_at
      last_content = last_moved_content.chapter_content

      if last_content.coursable_type == "Lesson"
        last_text = last_content.model.identifier
      else
        last_text = last_content.model.question_text
      end
    end
    return last_move, last_time, last_content, last_text, last_moved_content
  end

end
