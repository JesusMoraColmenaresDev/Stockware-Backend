class CategoriesController < ApplicationController
  before_action :set_category, only: [ :update, :destroy, :show ]

  def index
    @categories = Category.all
    render json: @categories
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
