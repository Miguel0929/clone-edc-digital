class Profesor::ProgramDetailsController < ApplicationController
	before_action :authenticate_user!
  before_action :require_profesor
	before_action :set_group
  before_action :set_program

  helper_method :get_program_stat
  helper_method :chapter_have_questions?

  add_breadcrumb "EDC DIGITAL", :root_path
  add_breadcrumb "Grupos", :profesor_groups_path

  def index
		if params[:query].present?
			@group = Group.find(params[:search_group])
			@program = Program.find(params[:search_program])
			@students = @group.student_search(params[:query])
		else
			@students = @group.active_students.all.order(:id)
		end
		p_chapters = chapter_have_questions?(@program)
		@questioned_chapters = p_chapters[0]
		@unquestioned_chapters = p_chapters[1]
		p_numbers = program_numbers(@students)
		@program_av_progress = p_numbers[0]
		@program_av_seen = p_numbers[1]
		@evaluated = User.joins(:program_stats).where(program_stats: {program_id: @program.id, user_id: @students.pluck(:id), checked: 1}).count
		add_breadcrumb "<a href='#{profesor_group_path(@group)}'>#{@group.name}</a>".html_safe
		add_breadcrumb "<a class='active' href='#{profesor_program_details_path(group_id: @group, program_id: @program)}'>Detalles de programa: #{@program.short_name}</a>".html_safe
	end

	private

	def set_group
    unless params[:query].present? then @group = Group.find(params[:group_id]) end
  end

  def set_program
    unless params[:query].present? then @program = Program.includes(:chapters).find(params[:program_id]) end
  end

  def get_program_stat(user, program)
    ProgramStat.where(user_id: user.id, program_id: program.id).last
  end

  def chapter_have_questions?(program)
    with_questions, no_questions = [], []
    program.chapters.each do |chapter|
      if chapter.questions.count > 0
        with_questions << chapter
      else
        no_questions << chapter
      end
    end
    return with_questions, no_questions
  end

  def program_numbers(students)
  	progress_array = []
  	seen_array = []
  	students.each do |student|
  		if !student.user_progress.nil? then progress_array.push(student.user_progress) end
  		if !student.user_seen.nil? then seen_array.push(student.user_seen) end
  	end
  	progress_av = (progress_array.inject(0.0){|sum,x| sum + x }) / progress_array.size
  	seen_av = (seen_array.inject(0.0){|sum,x| sum + x }) / seen_array.size
  	return (progress_av.to_f.nan? ? 0.0 : progress_av), (seen_av.to_f.nan? ? 0.0 : seen_av)
  end

end
