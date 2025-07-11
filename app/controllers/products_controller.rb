class ProductsController < ApplicationController
    before_action :set_product, only: [ :update, :destroy, :show ]


    def create
        @product = Product.new(product_params)
        if @product.save
            render json: @product, status: :created
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def index
        @products = Product.order(:id)
        render json: @products, methods: [ :image_url ]
    end

    def show
        render json: @product, status: :ok
    end

    def update
        if @product.update(product_params)
            render json: @product, status: :ok
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def destroy
        @product.destroy
        head :no_content
    end

    private

    def set_product
        @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Producto no encontrado" }, status: :not_found
    end

    def product_params
        params.require(:product).permit(:name, :price, :description, :category_id, :stock, :minimumQuantity, :image)
    end
end
