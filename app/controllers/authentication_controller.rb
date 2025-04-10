class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  # create test for method also create logout function
  def login
    Rails.logger.info "Attempting login for username: #{params[:username]}"
    begin
      @user = User.find_by(username: params[:username])
      if !@user
        Rails.logger.warn "User not found for username: #{params[:username]}"
        render json: { error: "User Not Found" }, status: :not_found
      elsif @user&.authenticate(params[:password])
          begin
            token = jwt_encode(user_id: @user.id)
            Rails.logger.info "Login successful for user ID: #{@user.id}"
            render json: { token: token }, status: :ok
          rescue JWT::EncodeError => e
            Rails.logger.error "JWT encoding error: #{e.message}"
            render json: { error: "Failed to generate token: #{e.message}" }, status: :internal_server_error
          end
      else
        Rails.logger.warn "Unauthorized login attempt for username: #{params[:username]}"
        render json: { error: "unauthorized" }, status: :unauthorized
      end
    rescue KeyError => e
      Rails.logger.warn "Missing parameters: #{e.message}"
      render json: { error: "bad request" }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error "Error during login: #{e.message}"
      render json: { error: "internal server error" }, status: :internal_server_error
    end
  end

  private

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
