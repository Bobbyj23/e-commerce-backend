class ApplicationController < ActionController::API
  # before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
      @decoded = jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end
end
