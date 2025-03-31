class ProductsController < ApplicationController
  def index
    @products = Product.all
    Rails.logger.info "Found #{@products.count} products"
    render json: @products || []
  end

  def show
    @product = Product.find(params[:id])

    Rails.logger.info "Found product #{@product.id}: #{@product.name}"
    render json: @product
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "Failed to find product with id #{params[:id]}"
    render json: { error: "Product not found" }, status: :not_found
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      Rails.logger.info "Created product #{@product.id}: #{@product.name}"
      render json: @product, status: :created
    else
      Rails.logger.info "Failed to create product: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:id])
    Rails.logger.info "Updating product #{@product.id}: #{@product.name}"

    if @product.update(product_params)
      Rails.logger.info "Updated product #{@product.id}: #{@product.name}"
      render json: @product
    else
      Rails.logger.info "Failed to update product #{@product.id}: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])

    Rails.logger.info "Deleting product #{@product.id}: #{@product.name}"
    @product.destroy

    Rails.logger.info "Deleted product #{@product.id}: #{@product.name}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info "Failed to delete product with id #{params[:id]}"
    render json: { error: "Product not found" }, status: :not_found
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :price)
  end
end
