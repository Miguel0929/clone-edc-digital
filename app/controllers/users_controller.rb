class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:students, :show]
  before_action :require_creator, only: [:students, :show]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :analytics_program]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{users_path}'>Estudiantes</a>".html_safe

    @users = User.students_table.page(params[:page]).per(100)

    if params[:state].present?
      case params[:state]
        when 'active'
          @users = @users.where.not(invitation_accepted_at: nil)
        when 'inactive'
          @users = @users.where(invitation_accepted_at: nil)
      end
    end

    if params[:answered].present?
      @users = @users.select do |user|
        percentage = (user.answers_count * 100) / user.questions_count rescue 0
        percentage_condition(percentage, params[:answered].to_i)
      end
    end

    if params[:visited].present?
      @users = @users.select do |user|
        percentage = (user.content_tracked_count * 100) / user.content_count rescue 0
        percentage_condition(percentage, params[:visited].to_i)
      end
    end

    @users = @users.where(group: params[:group]) if params[:group].present?

    respond_to do |format|
      format.html {}
      format.xls
    end
  end

  def show
    add_breadcrumb "Estudiantes", :users_path
    add_breadcrumb "<a class='active' href='#{user_path(@user)}'>#{@user.email}</a>".html_safe
  end

  def edit
    add_breadcrumb "Estudiantes", :users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_user_path(@user)}'>Editar información</a>".html_safe
  end

  def update
    add_breadcrumb "Estudiantes", :users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{edit_user_path(@user)}'>Editar información</a>".html_safe

    if @user.update(user_params)
      redirect_to @user, notice: "Se actualizó exitosamente el detalle del usuario #{@user.email}"
    else
      render :edit
    end
  end

  def destroy
    @user.destroy

    redirect_to users_path, notice: "Se eliminó exitosamente al usuario #{@user.email}"
  end

  def analytics_program
    @program = Program.find(params[:program_id])
    @chapter_contents = ChapterContent.joins(chapter: [:program]).where('programs.id = ?', @program.id).order(position: :asc)

    add_breadcrumb "Estudiantes", :users_path
    add_breadcrumb @user.email, user_path(@user)
    add_breadcrumb "<a class='active' href='#{analytics_program_user_path(@user, program_id: @program)}'>Detalles de programa</a>".html_safe
  end

  def students
    respond_to do |format|
      format.html do
        @users = User.students.includes(:group).page(params[:page]).per(100)

        if params[:state].present?
          case params[:state]
            when 'active'
              @users = @users.where.not(invitation_accepted_at: nil)
              @allusers = User.students.where.not(invitation_accepted_at: nil)
            when 'inactive'
              @users = @users.where(invitation_accepted_at: nil)
              @allusers = User.students.where(invitation_accepted_at: nil)
          end
        end

        if params[:group].present? && params[:state].present?
          case params[:state]
            when 'active'
              @users = @users.where(group: params[:group]).where.not(invitation_accepted_at: nil)
              @allusers = User.students.where(group: params[:group]).where.not(invitation_accepted_at: nil)
            when 'inactive'
              @users = @users.where(group: params[:group], invitation_accepted_at: nil)
              @allusers = User.students.where(group: params[:group], invitation_accepted_at: nil)
          end
          @group = Group.find(params[:group])
        elsif params[:group].present? && !params[:state].present?
          @users = @users.where(group: params[:group])
          @allusers = User.students.where(group: params[:group])
          @group = Group.find(params[:group])
        end

        @users = @users.search(params[:query]) if params[:query].present?
      end
      format.xlsx do
        fast = params[:fast] == 'true' ? true : false
        @users = User.students.includes(:group)
        @job = AsyncJob.create({title: 'Exporting csv', progress: 0, total: @users.count})
        exporter = Exporter.new
        exporter.file = Pathname('public/system/export.csv').open
        exporter.save
        StudentsExporterJob.perform_async(@job.id, @users, exporter, fast)
        redirect_to exporter_path(@job)
      end
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :group_id, :role)
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
      when 4
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
