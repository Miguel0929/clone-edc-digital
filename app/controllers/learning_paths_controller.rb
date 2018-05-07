class LearningPathsController < ApplicationController

  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_learning_path, only: [:show, :destroy, :edit, :update, :clone]
  before_action :blank_group_paths, only: [:destroy]
  after_action :update_program_sequences, only: [:destroy]
  include GroupHelper
  add_breadcrumb "EDCDIGITAL", :root_path
  def index
    add_breadcrumb "<a href='#{learning_paths_path}' class='active'>Rutas de aprendizaje</a>".html_safe
    @learning_path = LearningPath.all
  end
  def new
    add_breadcrumb "Ruta de aprendizaje", :learning_paths_path
    add_breadcrumb '<a class="active">Nueva "Ruta de aprendizaje"</a>'.html_safe
    @programs = Program.all
    @quizzes = Quiz.all
    @templates_refilables = TemplateRefilable.all
    @delireverable_packages = DelireverablePackage.all
  end

  def edit
    add_breadcrumb "Ruta de aprendizaje", :learning_paths_path
    add_breadcrumb "<a class='active' href='#{edit_learning_path_path(@learning_path)}'>#{@learning_path.name}</a>".html_safe
  end  

  def create
    @learning_path= LearningPath.new(name: params[:name], tipo: params[:tipo])

    if @learning_path.save
      if learning_path_params[:programs]
        programs=learning_path_params[:programs]
        c=0
        programs.each do |program|
          c+=1
          @learning_path.learning_path_contents.create(content_id: program, content_type: "Program",position: c)
        end 
      end
      if learning_path_params[:quizzes]
        quizzes=learning_path_params[:quizzes]
        c=0
        quizzes.each do |quiz|
          c+=1
          @learning_path.learning_path_contents.create(content_id: quiz, content_type: "Quiz",position: c)
        end 
      end
      if learning_path_params[:refilables]
        refilables=learning_path_params[:refilables]
        c=0
        refilables.each do |refilable|
          c+=1
          @learning_path.learning_path_contents.create(content_id: refilable, content_type: "TemplateRefilable",position: c)
        end 
      end
      if learning_path_params[:delireverables]
        delireverables=learning_path_params[:delireverables]
        c=0
        delireverables.each do |delireverable|
          c+=1
          @learning_path.learning_path_contents.create(content_id: delireverable, content_type: "DelireverablePackage",position: c)
        end 
      end

      redirect_to learning_path_path(@learning_path), notice: "Se creó la ruta \"#{@learning_path.name}\" exitosamente"
    else
      render :new
    end         
  end

  def update
    if learning_path_edit_params[:tipo] == "moral"
      if @learning_path.update(tipo: learning_path_edit_params[:tipo], name: learning_path_edit_params[:name], group2_ids:  learning_path_edit_params[:group2_ids])
        UpdateProgramSequenceJob.perform_async(Group.where(id: learning_path_edit_params[:group2_ids]))
        redirect_to learning_paths_path, notice: "Ruta de aprendizaje actualizada"
      else  
        render :edit
      end
    elsif  learning_path_edit_params[:tipo] == "fisica"
      if @learning_path.update(tipo: learning_path_edit_params[:tipo], name: learning_path_edit_params[:name], group_ids: learning_path_edit_params[:group_ids])
        UpdateProgramSequenceJob.perform_async(Group.where(id: learning_path_edit_params[:group_ids]))
        redirect_to learning_paths_path, notice: "Ruta de aprendizaje actualizada"
      else  
        render :edit
      end
    else
      if @learning_path.update(tipo: learning_path_edit_params[:tipo], name: learning_path_edit_params[:name])
        redirect_to learning_paths_path, notice: "Ruta de aprendizaje actualizada"
      else  
        render :edit
      end
    end         
  end  

  def show
    add_breadcrumb "Rutas de aprendizaje", :learning_paths_path
    add_breadcrumb "<a class='active' href='#{learning_path_path(@learning_path)}'>#{@learning_path.name}</a>".html_safe
    @programs = Program.all
    @quizzes = Quiz.all
    @templates_refilables = TemplateRefilable.all
    @delireverable_packages = DelireverablePackage.all
    @c_programs = @learning_path.learning_path_contents.where(content_type: "Program").order(:position)
    @c_quizzes = @learning_path.learning_path_contents.where(content_type: "Quiz").order(:position)
    @c_refilables = @learning_path.learning_path_contents.where(content_type: "TemplateRefilable").order(:position)
    @c_delireverables= @learning_path.learning_path_contents.where(content_type: "DelireverablePackage").order(:position)
  end

  def destroy
    @learning_path.destroy
    redirect_to learning_paths_path, notice: "Se eliminó exitosamente"  
  end

  def complementarios
    if params.has_key?(:r_fisica) && params.has_key?(:r_moral)
      @learning_path_fisica = LearningPath.find(params[:r_fisica]) rescue nil
      @learning_path_moral = LearningPath.find(params[:r_moral]) rescue nil

      ruta_f_p = []; ruta_f_q = []; ruta_f_d = []; ruta_f_r = []
      if @learning_path_fisica.nil?
        lpf_programs = []; lpf_quizzes = [],lpf_refilables = [], lpf_delireverables = []    
      else
        lpf_programs = @learning_path_fisica.learning_path_contents.where(content_type: "Program").pluck(:content_id)
        lpf_quizzes = @learning_path_fisica.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
        lpf_refilables = @learning_path_fisica.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
        lpf_delireverables = @learning_path_fisica.learning_path_contents.where(content_type: "DelireverablePackage").pluck(:content_id)
        @learning_path_fisica.learning_path_contents.each do |content|
          if content.content_type == "Program"
            ruta_f_p << {id: content.content_id, type: content.content_type, name: content.model.name}
          elsif content.content_type == "Quiz"
            ruta_f_q << {id: content.content_id, type: content.content_type, name: content.model.name}
          elsif content.content_type == "DelireverablePackage"  
            ruta_f_d << {id: content.content_id, type: content.content_type, name: content.model.name}
          elsif content.content_type == "TemplateRefilable"  
            ruta_f_r << {id: content.content_id, type: content.content_type, name: content.model.name}
          end  
        end
      end

      ruta_m_p = []; ruta_m_q = []; ruta_m_d = []; ruta_m_r = []
      if @learning_path_moral.nil?
        lpm_programs = []; lpm_quizzes = [],lpm_refilables = [], lpm_delireverables = []   
      else
        lpm_programs = @learning_path_moral.learning_path_contents.where(content_type: "Program").pluck(:content_id)
        lpm_quizzes = @learning_path_moral.learning_path_contents.where(content_type: "Quiz").pluck(:content_id)
        lpm_refilables = @learning_path_moral.learning_path_contents.where(content_type: "TemplateRefilable").pluck(:content_id)
        lpm_delireverables = @learning_path_moral.learning_path_contents.where(content_type: "DelireverablePackage").pluck(:content_id)
        @learning_path_moral.learning_path_contents.each do |content|
          if content.content_type == "Program"
            ruta_m_p << {id: content.content_id, type: content.content_type, name: content.model.name, position: content.position}
          elsif content.content_type == "Quiz"
            ruta_m_q << {id: content.content_id, type: content.content_type, name: content.model.name, position: content.position}
          elsif content.content_type == "DelireverablePackage"  
            ruta_m_d << {id: content.content_id, type: content.content_type, name: content.model.name, position: content.position}
          elsif content.content_type == "TemplateRefilable"  
            ruta_m_r << {id: content.content_id, type: content.content_type, name: content.model.name, position: content.position}
          end  
        end
      end

      programs = Program.where.not(id: lpf_programs + lpm_programs).select("id","name")
      quizzes =  Quiz.where.not(id: lpf_quizzes + lpm_quizzes).select("id","name")
      refilables = TemplateRefilable.where.not(id: lpf_refilables + lpm_refilables).select("id","name")
      delireverables = DelireverablePackage.where.not(id: lpf_delireverables + lpm_delireverables).select("id","name")
      render :json => {ruta_f_p: ruta_f_p, ruta_f_q: ruta_f_q, ruta_f_d: ruta_f_d, ruta_f_r: ruta_f_r, ruta_m_p: ruta_m_p, ruta_m_q: ruta_m_q, ruta_m_d: ruta_m_d, ruta_m_r: ruta_m_r, programs: programs, quizzes: quizzes, refilables: refilables, delireverables: delireverables}
    else
      render :json => {ruta_f_p: [], ruta_f_q: [], ruta_f_d: [], ruta_f_r: [], ruta_m_p: [], ruta_m_q: [], ruta_m_d: [], ruta_m_r: [], programs: [], quizzes: [], refilables: [], delireverables: []}  
    end
  end

  def clone
    learning_path = @learning_path.deep_clone  do |original, kopy|
       kopy.name = "#{original.name} copia"
       kopy.learning_path_contents = original.learning_path_contents.map(&:deep_clone)
    end
    learning_path.save
    redirect_to learning_paths_path, notice: "Se creo exitosamente la ruta #{learning_path.name}"
  end 

  private
    def set_learning_path
      @learning_path= LearningPath.find(params[:id])
    end
    def learning_path_params
      params.permit(:name, :tipo, programs: [], quizzes: [], refilables: [], delireverables: [])
    end
    def learning_path_edit_params
      params.require(:learning_path).permit(:name, :tipo, group_ids: [], group2_ids: [])
    end 
    def blank_group_paths
      if @learning_path.tipo == "fisica"
        @learning_path_groups = Group.where(learning_path_id: @learning_path.id)
        @learning_path_groups.each do |group|
          group.update(learning_path_id: nil)
        end
      elsif @learning_path.tipo == "moral"
        @learning_path_groups = Group.where(learning_path2_id: @learning_path.id)
        @learning_path_groups.each do |group|
          group.update(learning_path2_id: nil)
        end
      end
    end 
    def update_program_sequences
      #if @learning_path.tipo == "fisica"
      #  puts "es física we"
      #  groups = Group.where(learning_path_id: @learning_path.id)
      #elsif @learning_path.tipo == "moral"
      #  puts "es moral we"
      #  groups = Group.where(learning_path2_id: @learning_path.id)
      #end
      UpdateProgramSequenceJob.perform_async(@learning_path_groups)
    end
end
