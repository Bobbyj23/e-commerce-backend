class ProductsController < ApplicationController
  def index
    @products = policy_scope(Product)
    Rails.logger.info "ProductsController#index Found #{@products.count} products"
    render json: @products
  end

  def show
    @product = Product.find_by(id: params[:id])
    if @product
      authorize @product
      render json: @product
    else
      Rails.logger.warn "Product not found: #{params[:id]}"
      render json: { error: "Product not found" }, status: :not_found
    end
  end

  def create
    authorize Product
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created
    else
      Rails.logger.warn "ProductsController: Failed to create product: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:id])
    authorize @product

    if @product.update(product_params)
      render json: @product
    else
      Rails.logger.warn "Failed to update product #{@product.id}: #{@product.errors.full_messages}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Failed to update product #{@product.id}: Product not found"
    render json: "Product not found", status: :not_found
  end

  def destroy
    @product = Product.find(params[:id])
    authorize @product

    if @product.destroy
      Rails.logger.info "ProductsController: Deleted product #{@product.id}: #{@product.name}"
      head :no_content
    else
      Rails.logger.warn "ProductsController: Failed to delete product #{@product.id}: #{@product.name}"
      render json: @product.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Failed to delete product with id #{params[:id]}, Product not found"
    render json: "Product not found", status: :not_found
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :price)
  end
end
