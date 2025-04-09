

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:user) { FactoryBot.create(:user) }
  let!(:category) { FactoryBot.create(:category) }
  let!(:product) { FactoryBot.create(:product) }
  let!(:product2) { FactoryBot.create(:product) }
  let(:token) { JWT.encode(user.id, Rails.application.credentials.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before(:each) do
    request.headers.merge! headers
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'assigns all products to @products' do
      get :index
      expect(assigns(:products)).to match_array([ product, product2 ])
    end

    it 'renders a JSON response' do
      get :index
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)
    end

    it 'assigns the requested product to @product' do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end

    it 'renders a JSON response' do
      get :show, params: { id: product.id }
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns a not found status when product is not found' do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a not found error message' do
      get :show, params: { id: 999 }
      expect(JSON.parse(response.body)['error']).to eq('Product not found')
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { FactoryBot.attributes_for(:product, category_id: category.id) }

      it 'creates a new product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { product: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created product as JSON' do
        post :create, params: { product: valid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['id']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil } }

      it 'does not create a new product' do
        expect {
          post :create, params: { product: invalid_attributes }
        }.to_not change(Product, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { product: invalid_attributes }
        expect(response).to have_http_status(422)
      end

      it 'returns the errors as JSON' do
        post :create, params: { product: invalid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'New Name' } }

      it 'updates the product' do
        put :update, params: { id: product.id, product: new_attributes }
        product.reload
        expect(product.name).to eq('New Name')
      end

      it 'returns a successful response' do
        put :update, params: { id: product.id, product: new_attributes }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated product as JSON' do
        put :update, params: { id: product.id, product: new_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['name']).to eq('New Name')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil } }

      it 'does not update the product' do
        put :update, params: { id: product.id, product: invalid_attributes }
        product.reload
        expect(product.name).not_to be_nil
      end

      it 'returns an unprocessable entity status' do
        put :update, params: { id: product.id, product: invalid_attributes }
        expect(response).to have_http_status(422)
      end

      it 'returns the errors as JSON' do
        put :update, params: { id: product.id, product: invalid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the product' do
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)
    end

    it 'returns a no content status' do
      delete :destroy, params: { id: product.id }
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'product params' do
    controller = ProductsController.new
    let(:params_hash) { { product: { name: 'Test Product', description: 'Description', category_id: category.id, price: 10.00 } } }
    let(:params) { ActionController::Parameters.new(params_hash) }

    it 'permits name, description, category_id, and price' do
      controller.params = params
      permitted_params = controller.send(:product_params).to_h
      expected_params = params.require(:product).permit(:name, :description, :category_id, :price).to_h
      expect(permitted_params).to eq(expected_params)
    end
  end
end
