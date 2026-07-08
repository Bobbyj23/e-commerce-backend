require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { user_id: current_user.id }
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  let(:user) { FactoryBot.create(:user) }

  def token_for(user_id, exp: 24.hours.from_now)
    JWT.encode({ user_id: user_id, exp: exp.to_i }, Rails.application.credentials.secret_key_base)
  end

  it 'sets current_user for a valid token' do
    request.headers['Authorization'] = "Bearer #{token_for(user.id)}"
    get :index

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['user_id']).to eq(user.id)
  end

  it 'returns unauthorized when no Authorization header is present' do
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unauthorized for a malformed token' do
    request.headers['Authorization'] = 'Bearer not-a-real-token'
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unauthorized for an expired token' do
    request.headers['Authorization'] = "Bearer #{token_for(user.id, exp: 1.hour.ago)}"
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns not found when the token references a user that no longer exists' do
    token = token_for(user.id)
    user.destroy
    request.headers['Authorization'] = "Bearer #{token}"
    get :index

    expect(response).to have_http_status(:not_found)
  end
end
