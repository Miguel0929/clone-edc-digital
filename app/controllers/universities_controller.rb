class UniversitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_university, only:[:edit, :destroy, :update, :show]

  add_breadcrumb "EDC DIGITAL", :root_path
  def index
    add_breadcrumb "<a class='active' href='#{universities_path}'>Universidades</a>".html_safe
    @states=State.all
    @universities=University.order(:name).page(params[:page]).per(100)
  end
  def show
    add_breadcrumb "Universidades", :universities_path
    add_breadcrumb "<a class='active' href='#{universities_path(@university)}'>#{@university.name}</a>".html_safe
  end
  def new
    add_breadcrumb "Universidades", :universities_path
    add_breadcrumb "<a class='active' href='#{new_university_path}'>Crear universidad</a>".html_safe

    @university = University.new
  end
  def create
    @university = University.new(university_params)
    if @university.save
      redirect_to state_universities_path(state: @university.state_id), notice: "Se creo exitosamente la universidad #{@university.name}"
    else
      render :new
    end
  end 
  def state
    add_breadcrumb "Universidades", :universities_path
      add_breadcrumb "<a class='active' href='#{state_universities_path(state: params[:state].to_s)}'>#{State.find(params[:state]).name}</a>".html_safe
    @states=State.all
    if params[:state].present?
      @universities=University.where(state_id: params[:state]).order(:name).page(params[:page]).per(50)
      respond_to do |format|
          format.html
          format.json { render json: University.where(state_id: params[:state]).order(:name).map{ |c| [c.id,c.name] }.to_h }
      end
    else
      redirect_to universities_path
    end 
  end
  def edit
    add_breadcrumb "Universidad", :universities_path
    add_breadcrumb "<a class='active' href='#{edit_university_path(@university)}'>#{@university.name}</a>".html_safe
  end 
  def update
    if @university.update(university_params)
      redirect_to state_universities_path+"?state="+@university.state_id.to_s, notice: "Se actualizó exitosamente la universidad #{@university.name}"
    else
      render :edit
    end
  end
  def destroy
     st=@university.state_id
     @university.destroy
     redirect_to state_universities_path+"?state="+st.to_s, notice: "Se eliminó exitosamente la universidad #{@university.name}"
  end
  private
    def university_params
      params.require(:university).permit(:name, :state_id)
    end 
    def set_university
      @university=University.find(params[:id])
    end 
end
