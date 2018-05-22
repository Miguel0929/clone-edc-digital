class GroupStatsController < ApplicationController
  
  before_action :set_group, only: [:post]

  def post  
    seen, answered, evaluation = [], [], []
    @group.active_students.each do |student|
      if student.trackers.count > 0
        seen << student.content_visited_percentage
      else 
        seen << 0
      end
      answered << student.answered_questions_percentage
      evaluation << student.evaluation_status
    end

    if !seen.empty?
      av_seen = (seen.inject(0){ |sum, el| sum + el }.to_f / seen.size) rescue 0.0
    end
    if !answered.empty?
      av_answered = (answered.inject(0){ |sum, el| sum + el }.to_f / answered.size) rescue 0.0
    end

    active_students = @group.active_students.count
    total_unevaluated = evaluation.count("sin evaluar")
    total_evaluated = evaluation.size - total_unevaluated
    group_stats = GroupStat.find_by(group_id: @group.id)

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
