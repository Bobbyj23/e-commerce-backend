class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :update, :destroy ]

  def index
    @orders = current_user.orders
    Rails.logger.info "OrdersController#index Found #{@orders.count} orders"
    render json: @orders
  end

  def show
    render json: @order
  end

  def create
    @order = current_user.orders.new(order_params)
    if @order.save
      render json: @order, status: :created
    else
      Rails.logger.warn "ordersController: Failed to create order: #{@order.errors.full_messages}"
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @order.update(order_params)
    render json: @order
  end

  def destroy
    if @order.destroy
      Rails.logger.info "OrdersController#destroy - Successfully deleted order #{@order.id}"
      head :no_content
    else
      Rails.logger.warn "OrdersController#destroy - Error deleting order #{@order.id}: #{@order.errors.full_messages}"
      render json: { error: "#{@order.errors.full_messages}" }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "OrdersController#set_order - Error finding order with ID #{params[:id]}: #{e.message}"
    render json: { error: "Order not found" }, status: :not_found
    nil
  end

  def order_params
    params.require(:order).permit(:status, :total, :user_id, order_items_attributes: [ :product_id, :quantity, :price, :_destroy, :id ])
  end
end
