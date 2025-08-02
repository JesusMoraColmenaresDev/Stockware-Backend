class ProductsController < ApplicationController
    before_action :set_product, only: [ :update, :destroy, :show ]


    def create
        @product = Product.new(product_params)
        if @product.save
            render json: @product, include: :category, status: :created
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def index
        # 1. Empezamos con la consulta base de todos los productos.
        products = Product.where(is_enabled: true).includes(:category).order(:id)

        # 2. Si el parámetro 'search' está presente en la URL...
        if params[:search].present?
            # ...filtramos la consulta.
            # Usamos ILIKE para una búsqueda que no distingue mayúsculas/minúsculas (funciona en PostgreSQL).
            search_term = "%#{params[:search]}%"
            products = products.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
        end

        if params[:category_id].present?
            products = products.where(category_id: params[:category_id])
        end

        # esta definido en aplication controller
        # 3. Pasamos la consulta (ya sea la original o la filtrada) a nuestro método de paginación.
        respond_to do |format|
            format.json do
                # 3. Para JSON, pasamos la consulta (ya sea la original o la filtrada) a nuestro método de paginación.
                render_paginated(products, { methods: :image_url })
            end

            format.pdf do
                # Para PDF, creamos una instancia de nuestro generador y enviamos los datos.
                pdf = ProductReportPdf.new(products, current_user)
                send_data pdf.render,
                          type: "application/pdf",
                          disposition: "inline"
            end
        end
    end

    def show
        render json: @product, methods: :image_url, include: :category, status: :ok
    end

    def update
        if @product.update(product_params)
            render json: @product, status: :ok
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def destroy
        # @product.destroy
        # head :no_content
        # soft‑disable
        if @product.update(is_enabled: false)
            head :no_content
        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    private

    def set_product
        @product = Product.includes(:category).find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Producto no encontrado" }, status: :not_found
    end

    def product_params
        params.require(:product).permit(:name, :price, :description, :category_id, :stock, :minimumQuantity, :image)
    end
end
