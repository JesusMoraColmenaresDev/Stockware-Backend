class StockMovementsController < ApplicationController
  # before_action :authenticate_user!      # if you’re using Devise
  #  before_action :set_product, only: [ :create, :by_product ]
  # before_action :authenticate_user!, only: [ :create ]


  # GET /stock_movements
  def index
    # 1. Empezamos con la consulta base, incluyendo productos y usuarios para poder filtrar y mostrar sus datos.
    # Usamos `includes` para evitar N+1 queries. `references` es necesario para el `where` en tablas asociadas.
    movements = StockMovement.includes({ product: :category }, :user).references(:product).order(created_at: :desc)

    # 2. Filtrar por término de búsqueda en el nombre del producto.
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      # Buscamos en el nombre del producto asociado.
      movements = movements.where("products.name ILIKE ?", search_term)
    end

    # 3. Filtrar por ID de categoría del producto.
    if params[:category_id].present?
      movements = movements.where(products: { category_id: params[:category_id] })
    end

    if params[:start_date].present?
      begin
        # Parseamos la fecha y nos aseguramos de que sea el inicio del día.
        start_date = Date.parse(params[:start_date]).beginning_of_day
        movements = movements.where("stock_movements.created_at >= ?", start_date)
      rescue Date::Error
        render json: { error: "Formato de fecha de inicio inválido. Use YYYY-MM-DD." }, status: :bad_request
        return
      end
    end

    if params[:end_date].present?
      begin
        # Parseamos la fecha y la llevamos al final del día para que la búsqueda sea inclusiva.
        end_date = Date.parse(params[:end_date]).end_of_day
        movements = movements.where("stock_movements.created_at <= ?", end_date)
      rescue Date::Error
        render json: { error: "Formato de fecha de inicio inválido. Use YYYY-MM-DD." }, status: :bad_request
        return
      end
    end

    respond_to do |format|
      format.json do
        # 4. Para JSON, pasamos la consulta a nuestro método de paginación.
        render_paginated(movements, {
          include: {
            product: {
              methods: :image_url,
              include: { category: { only: [:id, :name] } }
            },
            user: { only: [:id, :name, :email, :is_enabled] }
          }
        })
      end

      format.pdf do
        pdf = StockReportPdf.new(movements)
        send_data pdf.render,
                  type: "application/pdf",
                  disposition: "inline" # 'inline' lo muestra en el navegador, 'attachment' lo descarga
      end
    end
  end

  # GET /stock_movements/:id
  def show
    movement = StockMovement.find(params[:id])
    render json: movement, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movement Not Found" }, status: :not_found
  end

  # GET /stock_movements/by_user/:user_id
  def by_user
    movements = StockMovement
                  .where(user_id: params[:user_id])
                  .order(created_at: :desc)
    render json: movements, status: :ok
  end

  # GET /stock_movements/by_product/:product_id
  def by_product
    movements = StockMovement
                  .where(product_id: params[:product_id])
                  .order(created_at: :desc)
    render json: movements, status: :ok
  end




  # POST /stock_movements
  # Body: { stock_movement: { product_id: 42, user_id: 7, quantity: -3 } }
  def create
    # @movement = @product.stock_movements.build(movement_params.merge(user: current_user))

    # Diferencia entre variables con @ o no, es que las de @ son de instancias, las que no son locales de este scope
    # movement = StockMovement.new(movement_params.except(:user_id)) # Seria la ignorar cosas del Payload en caso de ser necesario
    movement = StockMovement.new(movement_params)
    movement.user = current_user

    product = Product.find(movement.product_id)

    ActiveRecord::Base.transaction do # Pa Modificar en Ambos lados
      new_stock = product.stock + movement.movement

      if new_stock < 0
        movement.errors.add(:movement, "Convertiria el Stock a menor que 0, Imposible")
        raise ActiveRecord::RecordInvalid.new(movement)
      end

      product.update!(stock: new_stock) # Actualiza en productos
      movement.save! # Guarda la Transaccion
    end

    render json: movement, status: :created

  rescue ActiveRecord::RecordInvalid => invalid
    render json: { errors: invalid.record.errors.full_messages }, status: :unprocessable_entity
  end

  private
  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def movement_params
    params
      .require(:stock_movement)
      .permit(:product_id, :movement)
  end
end
