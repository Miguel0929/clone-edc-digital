class GlossariesController < ApplicationController
	before_action :authenticate_user!
	before_action :require_admin, except: [:show, :index]
	before_action :set_glossary, only: [:show, :edit, :update, :destroy]

	add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

	def show
		add_breadcrumb "Glosario", :glossary_categories_path
    	add_breadcrumb "<a class='active' href='#{glossary_category_path(@glossary.glossary_category_id)}'>#{GlossaryCategory.find(@glossary.glossary_category_id).title}</a>".html_safe	
	end

	def index
		add_breadcrumb "<a href='#{glossary_categories_path}'>Glosario</a>".html_safe
		add_breadcrumb "<a class='active' href='#{glossaries_path}'>Búsqueda de términos</a>".html_safe
		@glossarysearch = Glossary.search(params[:key])
		@search_term = (params[:key])
	end

	def new
		add_breadcrumb "Glosario", :glossary_categories_path
    	add_breadcrumb "<a class='active'>Nuevo término</a>".html_safe
		@glossary = Glossary.new
	end

	def create
		@glossary = Glossary.new(glossary_params)

	    if @glossary.save
	      redirect_to glossary_categories_path, notice: "Se creó exitosamente el término #{@glossary.term}"
	    else
	      render :new
	    end
	end

	def edit
		add_breadcrumb "Glosario", :glossary_categories_path
    	add_breadcrumb "<a href='#{glossary_category_path(@glossary.glossary_category_id)}'>#{GlossaryCategory.find(@glossary.glossary_category_id).title}</a>".html_safe
		add_breadcrumb "<a class='active'>Editar término</a>".html_safe
	end

	def update
		if @glossary.update(glossary_params)
      		redirect_to glossary_path(@glossary), notice: "Se actualizó exitosamente el término #{@glossary.term}"
	    else
	      render :edit
	    end	
	end

	def destroy
		@glossary.destroy
    	redirect_to glossary_categories_path, notice: "Se eliminó exitosamente el término #{@glossary.term}"
	end

	private
	def set_glossary
		@glossary = Glossary.find(params[:id])
	end

	def glossary_params
	   params.require(:glossary).permit(:term, :definition, :image, :glossary_category_id)
	end
end
