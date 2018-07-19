class AnalyticsStatesController < ApplicationController
	before_action :authenticate_user!
  before_action :require_admin_or_mentor_or_profesor
  before_action :set_state, only: [:show, :mentor_state_evaluated]
  add_breadcrumb "EDCDIGITAL", :root_path
  def show
 
    @stats = StudentEvaluatedState.where(state: @state).order(:state_id).includes(:program)
    @stats_points = StudentEvaluatedPointsState.where(state: @state).order(:state_id)
    @programs = Program.all
    @states = State.all.order(:id)
    
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a href='#{students_evaluated_analytics_panel_index_path}'>Alumnos evaluados</a>".html_safe
    add_breadcrumb "<a class='active' href='#{analytics_state_path(@state.slug)}'>Alumnos evaluados por estado</a>".html_safe
  end

  def create_state_advance
  	state = State.find(params[:state_id])
    programs = Program.all
    groups = Group.where(state: state)
    timestamp = Time.current.to_i
    
    redis = Redis.new
    redis.set("job_#{timestamp}", {
      total: programs.count,
      progress: 0
    }.to_json) 

    programs.each do |program|
      AnalyticsAvancesEstadosJob.perform_async(program, groups, state, "job_#{timestamp}")
    end

    flash[:notice] = "Calculando Avances"
    redirect_to state_progress_analytics_state_path(timestamp, state_id: state.id) 
  end	

  def state_progress
    @job_id = params[:id]
    @state = State.find(params[:state_id])
    add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    add_breadcrumb "<a class='active' href='#{state_progress_analytics_state_path(@job_id, state_id: @state.id)}'>Calculando estadisticas - Alumnos por estado</a>".html_safe
  end

  def mentor_state_evaluated
  	@mentors = Mentor.all.invitation_accepted
  	if params[:mentor_id].present?
  		@mentor = Mentor.find(params[:mentor_id])
  		@programs = Program.all
  		@sepsm = StudentEvaluatedPointsStateMentor.where(mentor_id: @mentor.id, state_id: @state.id)
  		add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    	add_breadcrumb "<a href='#{students_evaluated_analytics_panel_index_path}'>Alumnos evaluados</a>".html_safe
    	add_breadcrumb "<a href='#{analytics_state_path(@state.slug)}'>Alumnos evaluados por estado</a>".html_safe	
  		add_breadcrumb "<a class='active' href='#{mentor_state_evaluated_analytics_state_path(@state.slug, mentor_id: @mentor.id)}'>Alumnos evaluados por estado (Funnel Mentores)</a>".html_safe	
  	end
  	
  end

  def create_mentor_state_evaluated

  	mentor = Mentor.find(params[:mentor_id]) rescue nil
  	if mentor == nil
  		redirect_to mentor_state_evaluated_analytics_state_path, alert: "Selecciona un mentor."
	  else
	  	state = State.find(params[:state_id])
    	programs = Program.all
    	timestamp = Time.current.to_i
    	
   
	    redis = Redis.new
	    redis.set("job_#{timestamp}", {
	      total: programs.count,
	      progress: 0
	    }.to_json) 

	    programs.each do |program|
	      AnalyticsStateFunnelMentorJob.perform_async(program, mentor, state, "job_#{timestamp}")
	    end
	    flash[:notice] = "Calculando Avances"
	    redirect_to mentor_state_progress_analytics_state_path(timestamp, state_id: state.id, mentor_id: mentor.id)
    
	  end
	  def mentor_state_progress
	  	@job_id = params[:id]
	  	if params[:state_id].present?
    		@state = State.find(params[:state_id])
    	end
    	if params[:mentor_id].present?	
    		@mentor = Mentor.find(params[:mentor_id])
    	end
    	add_breadcrumb "<a href='#{analytics_panel_index_path}'>Panel de analíticos</a>".html_safe
    	add_breadcrumb "<a href='#{students_evaluated_analytics_panel_index_path}'>Alumnos evaluados</a>".html_safe
    	add_breadcrumb "<a href='#{analytics_state_path(@state.slug)}'>Alumnos evaluados por estado</a>".html_safe		
	  end  
   
  end	

  private
  def set_state  
  	slug = params[:id]
    @state = State.find_by(slug: slug) 
  end	
end	