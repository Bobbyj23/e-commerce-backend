class CategoriesController < ApplicationController
  def index
    Rails.logger.info "CategoriesController#index: Retrieving all categories"
    @categories = Category.all
    Rails.logger.info "Found #{@categories.count} categories"
    render json: @categories || []
  end

  def show
    Rails.logger.info "CategoriesController#show: Retrieving category with id #{params[:id]}"
    @category = Category.find_by(id: params[:id])

    if @category
      Rails.logger.info "Found category #{@category.id}: #{@category.name}"
      render json: @category
    else
      Rails.logger.info "Failed to find category with id #{params[:id]}"
      render json: { error: "Category not found" }, status: :not_found
    end
  end

  def create
    Rails.logger.info "CategoriesController#create: Creating a new category"
    @category = Category.new(category_params)

    if @category.save
      Rails.logger.info "Created category #{@category.id}: #{@category.name}"
      render json: @category, status: :created
    else
      Rails.logger.info "Failed to create category: #{@category.errors.full_messages}"
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def update
    Rails.logger.info "CategoriesController#update: Updating category with id #{params[:id]}"
    @category = Category.find_by(id: params[:id])

    if @category
      if @category.update(category_params)
        Rails.logger.info "Updated category #{@category.id}: #{@category.name}"
        render json: @category
      else
        Rails.logger.info "Failed to update category #{@category.id}: #{@category.errors.full_messages}"
        render json: @category.errors, status: :unprocessable_entity
      end
    else
      Rails.logger.info "Failed to find category with id #{params[:id]}"
      render json: { error: "Category not found" }, status: :not_found
    end
  end

  def destroy
    Rails.logger.info "CategoriesController#destroy: Deleting category with id #{params[:id]}"
    @category = Category.find(params[:id])

    if @category.destroy
      Rails.logger.info "Deleted category #{@category.id}: #{@category.name}"
    else
      Rails.logger.info "Failed to delete category #{@category.id}: #{@category.errors.full_messages}"
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
