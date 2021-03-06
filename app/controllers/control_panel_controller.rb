class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{}'>Estadisticas generales</a>".html_safe
    @users = User.all
    @mentor_messages = MentorHelp.all
    @massages = Mailboxer::Message.all
    @groups = Group.all
    @programs = Program.all
    @shared_attachments = SharedAttachment.all
    @attachments = Attachment.all
    @reports = Report.all
    @visits = Visit.where(started_at: 60.day.ago...Time.now)
    @track = timetrack2
    @actives = User.where(role: 0).where.not(invitation_accepted_at: nil).count
    @inactives = User.where(role: 0, invitation_accepted_at: nil).count
    @active_groups = Group.includes(:students).where(:users => {role: 0}).where.not(:users => {invitation_accepted_at: nil}).count
    @inactive_groups = Group.includes(:students).where(:users => {role: 0, invitation_accepted_at: nil}).count

    #@activados = User.where(invitation_created_at: 6.months.ago.to_date..Date.today).where.not(invitation_accepted_at: nil).select('invitation_created_at, count(invitation_created_at) as total')
    #.group(:invitation_created_at).map {|user| [user.invitation_created_at.strftime('%Y-%m-%d'), user.total]}

    #@inactivos = User.where(invitation_created_at: 6.months.ago.to_date..Date.today, invitation_accepted_at: nil).select('invitation_created_at, count(invitation_created_at) as total')
    #.group(:invitation_created_at).map {|user| [user.invitation_created_at.strftime('%Y-%m-%d'), user.total]}

    @promedio_sessiones = []
    Session.where( start: 40.day.ago...Time.now).group_by(&:day).each do |day, session|
      tiempo = 0
      session.each do |s|
        tiempo += s.time.to_i
      end
      @promedio_sessiones << [day, tiempo]
    end
  end

  def group_history
    ids_stu = UserTracker.all.pluck(:user_id)
    @students = User.where(id: ids_stu).page(params[:page]).per(20)
    if params[:query].present?
      query = params[:query]
      @students = @students.where('lower(users.first_name) LIKE lower(?) OR lower(users.last_name) LIKE lower(?) OR lower(users.email) LIKE lower(?)',"%#{query}%", "%#{query}%", "%#{query}%").page(params[:page]).per(20) 
    end
  end

  def students_status
    add_breadcrumb "<a href='#{control_panel_index_path}'>Estadisticas generales</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_status_control_panel_index_path}'>Status de estudiantes</a>".html_safe
    req = params[:students_type]
    case req 
    when nil
      @students = User.where(role: 0).all 
    when "actives"
      @students = User.where(role: 0).where.not(invitation_accepted_at: nil)
    when "inactives"
      @students = User.where(role: 0, invitation_accepted_at: nil)
    end
    @students = @students.search_query(params[:query]) if params[:query].present?
    @students = @students.page(params[:page]).per(100)
  end

  def active_groups
    add_breadcrumb "<a href='#{control_panel_index_path}'>Estadisticas generales</a>".html_safe
    add_breadcrumb "<a class='active' href='#{active_groups_control_panel_index_path}'>Grupos con estudiantes activos e inactivos</a>".html_safe
    req = params[:group_type]
    case req 
    when nil
      @groups = Group.all 
    when "actives"
      @groups = Group.includes(:students).where(:users => {role: 0}).where.not(:users => {invitation_accepted_at: nil})
    when "inactives"
      @groups = Group.includes(:students).where(:users => {role: 0, invitation_accepted_at: nil})
    end
    @groups = @groups.group_search(params[:query]) if params[:query].present?
    @groups = @groups.page(params[:page]).per(50)
  end  

  def students_list
    @group = Group.find(params[:id])
    req = params[:students_type]
    case req 
    when nil
      @students = @group.students.all 
    when "actives"
      @students = @group.students.where.not(invitation_accepted_at: nil)
    when "inactives"
      @students = @group.students.where(invitation_accepted_at: nil)
    end
    @students = @students.search_query(params[:query]) if params[:query].present?
    @students = @students.page(params[:page]).per(100)
    add_breadcrumb "<a href='#{control_panel_index_path}'>Estadisticas generales</a>".html_safe
    add_breadcrumb "<a href='#{active_groups_control_panel_index_path}'>Grupos con estudiantes activos e inactivos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{students_list_control_panel_path(@group)}'>Estudiantes del grupo #{@group.name}</a>".html_safe
  end

  private
  def timetrack1
    #Los sig queries piden todos los usuarios creados desde cierta semana hasta cierta semana, usando el arreglo 'weeks'
    weeks = (0..20).to_a.reverse
    track_active, track_inactive = [], []
    number_active, number_inactive = 0, 0
    weeks.each do |wk|
      second_week = wk.week.ago
      first_week = (wk - 1).week.ago
      number_active = number_active + User.where(invitation_created_at: second_week..first_week).where.not(invitation_accepted_at: nil).count
      number_inactive = number_inactive + User.where(invitation_created_at: second_week..first_week, invitation_accepted_at: nil).count
      track_active.insert(-1, [second_week.strftime("%d/%b/%Y"), number_active])
      track_inactive.insert(-1, [second_week.strftime("%d/%b/%Y"), number_inactive])
    end
    return [ {name: "Activos", data: track_active}, {name: "Inactivos", data: track_inactive} ]
  end

  def timetrack2
    #Los sig queries comienzan a contar desde el ??ltimo registro de cada condici??n (actives and inactives) usando el m??todo 'group_by_week'
    active = User.where(invitation_created_at: 20.week.ago..Time.now).where.not(invitation_accepted_at: nil).group_by_week(:invitation_created_at, week_start: :mon).count.to_a
    inactive = User.where(invitation_created_at: 20.week.ago..Time.now, invitation_accepted_at: nil).group_by_week(:invitation_created_at, week_start: :mon).count.to_a
    active_dates, inactive_dates = active.collect{|ac| ac[0]}, inactive.collect{|ina| ina[0]} #Crear dos arreglos solo con las fechas de cada quiery
    empty = (active_dates + inactive_dates).uniq.sort #Mergear los dos arreglos anteriores eliminando duplicados y organizando por fecha
    active_x, inactive_x = [], []
    empty.map{ |em| active_dates.include?(em) ? active_x.push(active.find{|a| a[0] == em}) : active_x.push([em,0]) } #Si el query est?? presente poner el elemento, si no poner 0
    empty.map{ |em| inactive_dates.include?(em) ? inactive_x.push(inactive.find{|i| i[0] == em}) : inactive_x.push([em,0]) } #Si el query est?? presente poner el elemento, si no poner 0
    active_num, inactive_num = 0, 0
    active_result = active_x.map{ |x| [ x[0].strftime("%d/%b/%Y"), active_num = active_num + x[1] ] } #Haciendo un arreglo acumulativo de los resultados
    inactive_result = inactive_x.map{ |y| [ y[0].strftime("%d/%b/%Y"), inactive_num = inactive_num + y[1] ] } #Haciendo un arreglo acumulativo de los resultados
    return [ {name: "Activos", data: active_result}, {name: "Inactivos", data: inactive_result} ]
  end
end
