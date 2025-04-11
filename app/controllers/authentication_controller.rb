class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    Rails.logger.info "AuthenticationController#login: Username: #{params[:username]}"
    @user = User.find_by(username: params[:username])

    if @user.nil?
      Rails.logger.warn "AuthenticationController: Authentication failed User Not Found"
      render json: { error: "User Not Found" }, status: :not_found
    elsif @user.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      render json: { token: token }, status: :ok
    else
      Rails.logger.warn "AuthenticationController#login: Authentication failed"
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  rescue KeyError => e
    Rails.logger.error "AuthenticationController#login: #{e.class}: #{e.message}"
    render json: { error: "Bad Request: #{e.message}" }, status: :bad_request
  rescue JWT::EncodeError => e
    Rails.logger.error "AuthenticationController#login: #{e.class}: #{e.message}"
    render json: { error: "Token Generation Failed: #{e.message}" }, status: :internal_server_error
  rescue StandardError => e
    Rails.logger.error "AuthenticationController#login: #{e.class}: #{e.message}"
    render json: { error: "Internal Server Error: #{e.message}" }, status: :internal_server_error
  end

  private

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
