require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:order) { FactoryBot.create(:order) }
  let(:product) { FactoryBot.create(:product) }
  let(:order_item) { FactoryBot.create(:order_item, order: order, product: product) }
  let(:token) { (JWT.encode(user.id, Rails.application.credentials.secret_key_base)) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    request.headers.merge! headers
  end

  describe 'GET #index' do
    it 'returns a succesful response' do
      get :index, params: { order_id: order.id }

      expect(response).to be_successful
    end

    it 'assigns the order items to the @order_items instance variable' do
      get :index, params: { order_id: order.id }
      expect(assigns(:order_items)).to eq([ OrderItem.last ])
    end

    it 'returns an error if the order is not found' do
      get :index, params: { order_id: 999 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #show' do
    it 'returns the order item' do
      get :show, params: { id: order_item.id }

      expect(assigns(:order_item)).to eq(order_item)
    end

    it 'returns an error if the order item is not found' do
      get :show, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    it 'returns a created response' do
      post :create, params: { order_id: order.id, order_item: { product_id: product.id, quantity: 2 } }

      expect(response).to have_http_status(:created)
    end

    it 'creates a new order item' do
      expect { post :create, params: { order_id: order.id, order_item: { product_id: product.id, quantity: 2 } } }.to change(OrderItem, :count).by(2)
    end

    it 'returns an error if the order item is not created' do
      post :create, params: { order_id: order.id, order_item: { product_id: nil, quantity: 2 } }

      expect(response).to have_http_status(422)
    end
  end

  describe 'PUT #update' do
    it 'updates the order item' do
      put :update, params: { id: order_item.id, order_item: { quantity: 3 } }

      expect(order_item.reload.quantity).to eq(3)
    end

    it 'returns an error if the order item is not updated' do
      put :update, params: { id: order_item.id, order_item: { product_id: nil } }

      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)).to include('errors' => [ "Product must exist", "Product can't be blank" ])
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the order item' do
      delete :destroy, params: { id: order_item.id }

      expect(response).to be_no_content
    end

    it 'returns an error if the order item is not destroyed' do
      delete :destroy, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to include('error' => 'Order item not found')
    end
  end

  context 'unauthorized users' do
    before do
      request.headers["Authorization"] = nil
    end

    it 'returns a 401 error for GET #index' do
      get :index, params: { order_id: order.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 error for GET #show' do
      get :show, params: { id: order_item.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 error for POST #create' do
      post :create, params: { order_id: order.id, order_item: { product_id: product.id, quantity: 2 } }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 error for PUT #update' do
      put :update, params: { id: order_item.id, order_item: { quantity: 3 } }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a 401 error for DELETE #destroy' do
      delete :destroy, params: { id: order_item.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
