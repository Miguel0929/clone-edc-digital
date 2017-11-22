class GlossaryCategoriesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_category, only: [:edit, :show, :update, :destroy]
	helper_method :owner_category

	add_breadcrumb "EDC DIGITAL", :root_path

	def index
		add_breadcrumb "<a class='active' href='#{glossary_categories_path}'>Glosario</a>".html_safe

		@categories = GlossaryCategory.all
		@glossaries = Glossary.all
	end

	def show
		add_breadcrumb "Glosario", :glossary_categories_path
		add_breadcrumb "<a class='active' href='#{glossary_category_path(@category)}'> #{@category.title}</a>".html_safe
		
	end

	def new
		add_breadcrumb "Glosario", :glossary_categories_path
		add_breadcrumb "<a class='active'>Nueva categoría</a>".html_safe
		@category = GlossaryCategory.new
	end

	def create
		@category = GlossaryCategory.new(category_params)

		if @category.save
		  redirect_to new_glossary_path, notice: "Se creó exitosamente la categoría #{@category.title}"
		else
		  render :new
		end
	end

	def edit
		add_breadcrumb "Glosario", :glossary_categories_path
		add_breadcrumb "<a href='#{glossary_category_path(@category)}'>#{@category.title}</a>".html_safe
		add_breadcrumb "<a class='active'>Editar categoría</a>".html_safe
	end

	def update
		if @category.update(category_params)
			redirect_to glossary_categories_path, notice: "Se actualizó exitosamente la categoría #{@category.title}"
		else
			render :edit
		end
	end

	def destroy
		@category.destroy
		redirect_to glossary_categories_path, notice: "Se eliminó exitosamente la categoría #{@category.title}"
	end

	def owner_category(glossary)
		GlossaryCategory.find(glossary.glossary_category_id)
	end

  private
  def category_params
		params.require(:glossary_category).permit(:title, :term)
  end

  def set_category
		@category = GlossaryCategory.find(params[:id])
  end
end
