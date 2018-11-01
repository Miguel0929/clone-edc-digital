class FrequentsController < ApplicationController
	before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
	before_action :set_frequent, only: [:show, :edit, :update, :destroy]
	before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]
	add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

	def show
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
    	add_breadcrumb "<a class='active' href='#{frequent_category_path(@frequent.frequent_category_id)}'>#{FrequentCategory.find(@frequent.frequent_category_id).name}</a>".html_safe	
    	if current_user.nil?
			render layout: "layouts/politicas"
		end	
	end

	def index
		add_breadcrumb "<a href='#{frequent_categories_path}'>Preguntas frecuentes</a>".html_safe
		add_breadcrumb "<a class='active' href='#{frequents_path}'>Búsqueda de preguntas frecuentes</a>".html_safe
		@frequentsearch = Frequent.search(params[:term])
		@search_term = (params[:term])
		if current_user.nil?
			render layout: "layouts/politicas"
		end	
	end

	def new
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
    	add_breadcrumb "<a class='active'>Nueva pregunta</a>".html_safe
		@frequent = Frequent.new
	end

	def create
		@frequent = Frequent.new(frequent_params)

	    if @frequent.save
	      redirect_to frequent_categories_path, notice: "Se creó exitosamente la pregunta #{@frequent.name}"
	    else
	      render :new
	    end
	end

	def edit
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
    	add_breadcrumb "<a href='#{frequent_category_path(@frequent.frequent_category_id)}'>#{FrequentCategory.find(@frequent.frequent_category_id).name}</a>".html_safe
		add_breadcrumb "<a class='active'>Editar pregunta</a>".html_safe
	end

	def update
		if @frequent.update(frequent_params)
      		redirect_to frequent_path(@frequent), notice: "Se actualizó exitosamente la pregunta #{@frequent.name}"
	    else
	      render :edit
	    end	
	end

	def destroy
		@frequent.destroy
    	redirect_to frequent_categories_path, notice: "Se eliminó exitosamente la pregunta #{@frequent.name}"
	end

	private
	def set_frequent
		@frequent = Frequent.find(params[:id])
	end

	def frequent_params
	   params.require(:frequent).permit(:name, :answer, :frequent_category_id)
	end

end
