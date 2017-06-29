class GroupStatsController < ApplicationController
  
  before_action :set_group, only: [:post]

  def post	
  	seen, answered, evaluation = [], [], []
  	@group.students.each do |student|
  		seen << student.content_visited_percentage
  		answered << student.answered_questions_percentage
  		evaluation << student.evaluation_status
  	end
  	if !seen.empty?
  		av_seen = (seen.inject(0){ |sum, el| sum + el }.to_f / seen.size)
  	end
  	if !answered.empty?
  		av_answered = (answered.inject(0){ |sum, el| sum + el }.to_f / answered.size)
  	end
  	active_students = @group.students.count
  	total_unevaluated = evaluation.count("sin evaluar")
  	total_evaluated = evaluation.size - total_unevaluated
  	group_stats = GroupStat.where(group_id: @group.id).last

  	url = "#{URI(request.referer)}"

  	if group_stats.nil?
  		new_stats = GroupStat.create(group_id: @group.id, group_students: active_students, average_progress: av_answered, average_seen: av_seen, evaluated_students: total_evaluated, unevaluated_studets: total_unevaluated)
  		redirect_to url, notice: "Se crearon estadísticos para el grupo #{@group.name}"
  	else
  		updated_stats = group_stats.update(group_id: @group.id, group_students: active_students, average_progress: av_answered, average_seen: av_seen, evaluated_students: total_evaluated, unevaluated_studets: total_unevaluated)
  		redirect_to url, notice: "Se actualizaron los estadísticos del grupo #{@group.name}"
  	end
  end

  private
  def set_group
    @group = Group.find(params[:id])
  end
end
