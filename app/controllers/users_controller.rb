class UsersController < ApplicationController
  def create
    Rails.logger.info "UsersController#create: Creating a new user"
    @user = User.new(user_params)

    if @user.save
      Rails.logger.info "Created user #{@user.id}: #{@user.email}"
      render json: @user, status: :created
    else
      Rails.logger.info "Failed to create user: #{@user.errors.full_messages}"
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
