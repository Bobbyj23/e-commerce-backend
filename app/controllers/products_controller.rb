class ProductsController < ApplicationController
  def index
    @products = Product.all
    Rails.logger.info "ProductsController#index Found #{@products.count} products"
    render json: @products || []
  end

  def show
    @product = Product.find(params[:id])
    Rails.logger.info "ProductsController#show Found product #{@product.id}: #{@product.name}"
    render json: @product
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "ProductsController#show Failed to find product with id: #{params[:id]}"
    render json: { error: "Product not found" }, status: :not_found
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      Rails.logger.info "ProductsController#create Created product #{@product.id}: #{@product.name}"
      render json: @product, status: :created
    else
      Rails.logger.info "ProductsController#create Failed to create product: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:id])
    Rails.logger.info "ProductsController#update Updating product #{@product.id}: #{@product.name}"

    if @product.update(product_params)
      Rails.logger.info "Updated product #{@product.id}: #{@product.name}"
      render json: @product
    else
      Rails.logger.info "Failed to update product #{@product.id}: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "No product found with id: #{params[:id]}"
    render json: "Product not found", status: :not_found
  end

  def destroy
    @product = Product.find(params[:id])

    if @product.destroy
      Rails.logger.info "ProductsController#destroy: Deleted product #{@product.id}: #{@product.name}"
    else
      Rails.logger.info "ProductsController#destroy: Failed to delete product #{@product.id}: #{@product.name}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "Failed to delete product with id #{params[:id]}, Product not found"
    render json: "Product not found", status: :not_found
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :price)
  end
end
