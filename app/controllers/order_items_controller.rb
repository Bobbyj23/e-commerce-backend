class OrderItemsController < ApplicationController
  before_action :set_order, only: [ :index, :create ]
  before_action :set_order_item, only: [ :show, :update, :destroy ]

  def index
    @order_items = @order.order_items.all
    Rails.logger.info "OrderItemsController#index - Found #{@order_items.count} order items"
    render json: @order_items
  rescue => e
    Rails.logger.error "OrderItemsController#index - Error fetching order items: #{e.message}"
    render json: { error: "Failed to fetch order items" }, status: :internal_server_error
  end

  def show
    render json: @order_item
  end

  def create
    @order_item = @order.order_items.build(order_item_params)
    if @order_item.save
      render json: @order_item, status: :created
    else
      Rails.logger.warn "OrderItemsController - Failed to create order item: #{@order_item.errors.full_messages}"
      render json: { errors: @order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @order_item.update(order_item_params)
      render json: @order_item
    else
      Rails.logger.warn "OrderItemsController - Failed to update order item: #{@order_item.errors.full_messages}"
      render json: { errors: @order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @order_item.destroy
      Rails.logger.info "OrderItemsController#destroy - Successfully deleted order item #{@order_item.id}"
      head :no_content
    else
      Rails.logger.warn "OrderItemsController#destroy - Failed to delete order item: #{@order_item.errors.full_messages}"
      render json: { errors: @order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order =Order.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "OrderItemsController#set_order - Error finding order with id #{params[:order_id]}: Record not found"
    render json: { error: "Order not found" }, status: :not_found
    nil
  end

  def set_order_item
    begin
      if params[:order_id].present?
        @order_item = @order.order_items.find(params[:id])
      else
        @order_item = OrderItem.find(params[:id])
      end
      @order_item
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "OrderItemsController#set_order_item - Error finding order item with ID #{params[:id]}: #{e.message}"
      render json: { error: "Order item not found" }, status: :not_found
      nil
    end
  end

  def order_item_params
    params.require(:order_item).permit(:product_id, :quantity)
  end
end
