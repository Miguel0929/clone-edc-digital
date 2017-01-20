class Mentor::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_mentor
  before_action :set_comments, only: [:index, :archived, :news]

  add_breadcrumb "EDCDIGITAL", :root_path

  def index
  end

  def archived
    @comments = @comments.where('comments.archived = ?', true)
  end

  def news
    @comments = @comments.where('comments.archived = ?', false)
  end

  def create
    @comment = current_user.comments.new(comment_params)

    @comment_to_reply = Comment.find_by(id: params[:comment_id])

    @comment_to_reply.update(archived: true) if @comment_to_reply

    if @comment.save
      flash[:notice] = "Comentario respondido"
    end

    redirect_to params[:origin]
  end

  def update
    @comment = Comment.find(params[:id])

    @comment.update(archived: true)

    redirect_to params[:origin], notice: 'Comentario archivado'
  end

  private
  def set_comments
    @comments = Comment.select(
      'comments.*, users.first_name, users.last_name, questions.question_text, programs.name as program_name, chapter_contents.id as chapter_content_id, answers.id as answer_id'
    )
    .joins(:user, answer: [:question])
    .joins("INNER JOIN chapter_contents on chapter_contents.coursable_id = questions.id and coursable_type = 'Question'")
    .joins("INNER JOIN chapters on chapter_contents.chapter_id = chapters.id")
    .joins("INNER JOIN programs on programs.id = chapters.program_id")
    .where("users.id in (?)", current_user.groups.joins(:active_students).select('users.id'))
    .order(created_at: :desc)
  end

  def comment_params
    params.require(:comment).permit(:content, :answer_id)
  end
end
