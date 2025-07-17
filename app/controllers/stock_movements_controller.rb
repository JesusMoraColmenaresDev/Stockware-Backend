class StockMovementsController < ApplicationController
  # before_action :authenticate_user!      # if you’re using Devise
  #  before_action :set_product, only: [ :create, :by_product ]
  # before_action :authenticate_user!, only: [ :create ]


  # GET /stock_movements
  def index
    movements = StockMovement.all.order(created_at: :desc)
    render json: movements, status: :ok
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
