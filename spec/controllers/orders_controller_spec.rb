require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let!(:user) { FactoryBot.create(:user) }
  let!(:order) { FactoryBot.create(:order, user: user) }
  let(:token) { (JWT.encode(user.id, Rails.application.credentials.secret_key_base)) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge! headers
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns the orders to the @orders instance variable' do
      get :index
      expect(assigns(:orders)).to eq(user.orders)
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: order.id }
      expect(response).to be_successful
    end

    it 'assigns the order to the @order instance variable' do
      get :show, params: { id: order.id }
      expect(assigns(:order)).to eq(order)
    end
  end

  describe 'POST #create' do
  let!(:product) { FactoryBot.create(:product, price: 5.99) }
    it 'creates a new order' do
      expect { post :create, params: { order: { status: 'pending', total: 10.99, order_items_attributes: [ product_id: product.id, quantity: 2 ] } } }.to change(Order, :count).by(1)
    end

    it 'returns a created response' do
      post :create, params: { order: { status: 'pending', total: 10.99, order_items_attributes: [  product_id: product.id, quantity: 2 ] } }
      expect(response).to have_http_status(:created)
    end

    it 'does not create a new order with invalid params' do
      expect { post :create, params: { order: { status: nil, total: nil } } }.not_to change(Order, :count)
    end

    it 'returns an unprocessable entity response with invalid params' do
      post :create, params: { order: { status: nil, total: nil } }
      expect(response).to have_http_status(422)
    end
  end

  describe 'PATCH #update' do
    it 'updates the order' do
      patch :update, params: { id: order.id, order: { status: 'shipped' } }
      expect(order.reload.status).to eq('shipped')
    end

    it 'returns a successful response' do
      patch :update, params: { id: order.id, order: { status: 'shipped' } }
      expect(response).to be_successful
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the order' do
      expect { delete :destroy, params: { id: order.id } }.to change(Order, :count).by(-1)
    end

    it 'returns a no content response' do
      delete :destroy, params: { id: order.id }
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'set_order' do
    it 'sets the order instance variable' do
      get :show, params: { id: order.id }
      expect(assigns(:order)).to eq(order)
    end

    it 'returns a not found response with an invalid id' do
      get :show, params: { id: 'invalid' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
