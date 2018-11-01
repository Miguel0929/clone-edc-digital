class RefilableDefaultCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: :get_comment
  before_action :set_comment, only: [:show, :destroy, :edit, :update]
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
  	add_breadcrumb "<a class='active' href='#{refilable_default_comments_path}'>Comentarios de plantillas</a>".html_safe
  	if params[:program].present?
  	  template_refilables = TemplateRefilable.joins(:program).where(programs: {id: params[:program]}).pluck(:id)
  	  @comments = RefilableDefaultComment.joins(:template_refilable).where(template_refilables: {id: template_refilables})
  	else
  	  @comments = RefilableDefaultComment.all
  	end
  end

  def edit
  	add_breadcrumb "<a href='#{refilable_default_comments_path}'>Comentarios de plantillas</a>".html_safe
  	add_breadcrumb "<a  class='active' href='#{edit_refilable_default_comment_path}'>Editar comentario de plantilla</a>".html_safe
  end

  def update
    if @comment.update(refilable_default_comment_params)
      redirect_to refilable_default_comments_path, notice: 'Comentario de plantilla actualizado'
    else
      render :edit
    end
  end

  def new
  	add_breadcrumb "<a href='#{refilable_default_comments_path}'>Comentarios de plantillas</a>".html_safe
  	add_breadcrumb "<a  class='active' href='#{new_refilable_default_comment_path}'>Nuevo comentario de plantilla</a>".html_safe
  	@comment = RefilableDefaultComment.new
  end

  def create
    @comment = RefilableDefaultComment.new(refilable_default_comment_params)
    if @comment.save
      redirect_to refilable_default_comments_path, notice: 'Comentario de plantilla creado'
    else
      render :new
    end
  end

  def destroy
    @comment.destroy
    redirect_to refilable_default_comments_path, notice: 'Comentario de plantilla eliminado'
  end

  def get_comment
  	@comment = RefilableDefaultComment.find(params[:comment].to_i)
  	respond_to do |format|
      format.json { render json: {comment: @comment.content} }
    end
  end

  private
    def set_comment
      @comment = RefilableDefaultComment.find(params[:id])
    end

    def refilable_default_comment_params
      params.require(:refilable_default_comment).permit(:name, :template_refilable_id, :content)
    end
end