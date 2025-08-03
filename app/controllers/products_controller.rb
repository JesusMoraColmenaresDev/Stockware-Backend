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
                pdf = ProductReportPdf.new(products)
                send_data pdf.render,
                          type: "application/pdf",
                          disposition: "inline"
            end
        end
    end

    def show
        render json: @product, methods: :image_url, include: :category, status: :ok
    end

    # PATCH /products/:id
    def update
        # 1. Load product and remember current stock
        @product   = Product.includes(:category).find(params[:id])
        old_stock  = @product.stock

        # 2. Pull out :stock from the incoming params, so .update won't touch it
        incoming  = product_params.to_h
        new_stock = incoming.delete("stock")  # string key via to_h; or use symbol if you prefer

        # 3. Update all other attributes first
        if @product.update(incoming)
        # 4. Only if a new_stock was given AND it really changed...
        if new_stock.present? && new_stock.to_i != old_stock
            movement_qty = new_stock.to_i - old_stock

            # 5. Build the movement exactly as in your StockMovementsController#create
            movement = StockMovement.new(
            product:  @product,
            movement: movement_qty               # + added, – removed
            )
            movement.user  = current_user         # who did it
            movement.price = @product.price       # snapshot price

            ActiveRecord::Base.transaction do
            # 6a. Apply the stock update (just once)…
            @product.update!(stock: new_stock)

            # 6b. …and record the movement
            movement.save!
            end
        end

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
