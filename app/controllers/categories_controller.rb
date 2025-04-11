class CategoriesController < ApplicationController
  def index
    @categories = Category.all
    Rails.logger.info "CategoriesController#index Found #{@categories.count} categories"
    render json: @categories
  end

  def show
    @category = Category.find_by(id: params[:id])

    if @category
      render json: @category
    else
      Rails.logger.warn "Category not found"
      render json: { error: "Category not found" }, status: :not_found
    end
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created
    else
      Rails.logger.warn "Failed to create @category: #{@category.errors.full_messages}"
      render json: @category.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @category = Category.find(params[:id])

    if @category.update(category_params)
      render json: @category
    else
      Rails.logger.warn "Failed to update @category #{@category.id}: #{@category.errors.full_messages}"
      render json: @category.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Failed to find category with id #{params[:id]}"
    render json: { error: "Category not found" }, status: :not_found
  end

  def destroy
    @category = Category.find(params[:id])

    if @category.destroy
      Rails.logger.info "Deleted category #{@category.id}: #{@category.name}"
      head :no_content
    else
      Rails.logger.warn "Failed to delete category #{category.id}: #{category.errors.full_messages}"
      render json: @category.errors.full_messages, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "No category found to destroy"
    render json: "No Category found to destroy", status: :not_found
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
