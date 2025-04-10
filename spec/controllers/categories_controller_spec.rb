require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let!(:user) { FactoryBot.create(:user) }
  let!(:category) { FactoryBot.create(:category) }
  let!(:category2) { FactoryBot.create(:category) }
  let(:token) { JWT.encode(user.id, Rails.application.credentials.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before(:each) do
    request.headers.merge! headers
  end

  # add a context for unauthorized requests
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'assigns all categories to @categories' do
      get :index
      expect(assigns(:categories)).to match_array([ category, category2 ])
    end

    it 'renders a JSON response' do
      get :index
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:ok)
    end

    it 'assigns the requested category to @category' do
      get :show, params: { id: category.id }
      expect(assigns(:category)).to eq(category)
    end

    it 'renders a JSON response' do
      get :show, params: { id: category.id }
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns a not found status when category is not found' do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a not found error message' do
      get :show, params: { id: 999 }
      expect(JSON.parse(response.body)['error']).to eq('Category not found')
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) { FactoryBot.attributes_for(:category) }

      it 'creates a new category' do
        expect {
          post :create, params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { category: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created category as JSON' do
        post :create, params: { category: valid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['id']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil } }

      it 'does not create a new category' do
        expect {
          post :create, params: { category: invalid_attributes }
        }.to_not change(Category, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { category: invalid_attributes }
        expect(response).to have_http_status(422)
      end

      it 'returns the errors as JSON' do
        post :create, params: { category: invalid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'New Name' } }

      it 'updates the category' do
        put :update, params: { id: category.id, category: new_attributes }
        category.reload
        expect(category.name).to eq('New Name')
      end

      it 'returns a successful response' do
        put :update, params: { id: category.id, category: new_attributes }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated category as JSON' do
        put :update, params: { id: category.id, category: new_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['name']).to eq('New Name')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil } }

      it 'does not update the category' do
        put :update, params: { id: category.id, category: invalid_attributes }
        category.reload
        expect(category.name).not_to be_nil
      end

      it 'returns an unprocessable entity status' do
        put :update, params: { id: category.id, category: invalid_attributes }
        expect(response).to have_http_status(422)
      end

      it 'returns the errors as JSON' do
        put :update, params: { id: category.id, category: invalid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the category' do
      expect {
        delete :destroy, params: { id: category.id }
      }.to change(Category, :count).by(-1)
    end

    it 'returns a no content status' do
      delete :destroy, params: { id: category.id }
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'category params' do
    controller = CategoriesController.new
    let(:params_hash) { { category: { name: 'Test Category' } } }
    let(:params) { ActionController::Parameters.new(params_hash) }

    it 'permits name' do
      controller.params = params
      permitted_params = controller.send(:category_params).to_h
      expected_params = params.require(:category).permit(:name).to_h
      expect(permitted_params).to eq(expected_params)
    end
  end
end
