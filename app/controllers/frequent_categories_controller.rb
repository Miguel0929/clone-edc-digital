class FrequentCategoriesController < ApplicationController
	#before_action :authenticate_user!
	before_action :set_category, only: [:edit, :show, :update, :destroy]

	add_breadcrumb "EDC DIGITAL", :root_path

	def index
		add_breadcrumb "<a class='active' href='#{frequent_categories_path}'>Preguntas frecuentes</a>".html_safe

		@categories = FrequentCategory.all
		if current_user.nil?
			render layout: "layouts/politicas"
		end	
	end

	def show
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
		add_breadcrumb "<a class='active' href='#{frequent_category_path(@category)}'> #{@category.name}</a>".html_safe
		@frequents = @category.frequents.page(params[:page]).per(15)

		if current_user.nil?
			render layout: "layouts/politicas"
		end
		
	end

	def new
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
		add_breadcrumb "<a class='active'>Nueva categoría</a>".html_safe
		@category = FrequentCategory.new
	end

	def create
		@category = FrequentCategory.new(category_params)

		if @category.save
		  redirect_to new_frequent_path, notice: "Se creó exitosamente la categoría #{@category.name}"
		else
		  render :new
		end
	end

	def edit
		add_breadcrumb "Preguntas frecuentes", :frequent_categories_path
		add_breadcrumb "<a href='#{frequent_category_path(@category)}'>#{@category.name}</a>".html_safe
		add_breadcrumb "<a class='active'>Editar categoría</a>".html_safe
	end

	def update
		if @category.update(category_params)
			redirect_to frequent_categories_path, notice: "Se actualizó exitosamente la categoría #{@category.name}"
		else
			render :edit
		end
	end

	def destroy
		@category.destroy
		redirect_to frequent_categories_path, notice: "Se eliminó exitosamente la categoría #{@category.name}"
	end

	private
  def category_params
		params.require(:frequent_category).permit(:name, :term, :description)
  end

  def set_category
		@category = FrequentCategory.find(params[:id])
  end

end
