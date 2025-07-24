class CategoriesController < ApplicationController
  before_action :set_category, only: [ :update, :destroy, :show ]

  def index
    # 1. Empezamos con la consulta base de todas las categorias.
    categories = Category.order(:name)

    # 2. Si el parámetro 'search' está presente en la URL, filtramos.
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      categories = categories.where("name ILIKE ?", search_term)
    end
    render_paginated(categories)
  end

  # GET /categories/all
  def all
    categories = Category.order(:name)
    render json: categories, status: :ok
  end

  def show
      render json: @category, status: :ok
  end

  def create
    @category = Category.new(category_params)
    if @category.save()
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, status: :ok
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy()
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Categoría no encontrada" }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
