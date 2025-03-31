require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: FactoryBot.attributes_for(:user) }
        }.to change(User, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { user: FactoryBot.attributes_for(:user) }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created user as JSON' do
        post :create, params: { user: FactoryBot.attributes_for(:user) }
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse(response.body)['id']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect {
          post :create, params: { user: { username: nil } }
        }.to_not change(User, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: { user: { username: nil } }
        expect(response).to have_http_status(422)
      end

      it 'returns the errors as JSON' do
        post :create, params: { user: { username: nil } }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    describe 'user params' do
      controller = UsersController.new
        it 'permits username, email, password, and password_confirmation' do
          params_hash = { user: { username: 'test', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
          params = ActionController::Parameters.new(params_hash)
          controller.params = params
          permitted_params = controller.send(:user_params).to_h
          expected_params = params.require(:user).permit(:username, :email, :password, :password_confirmation).to_h
          expect(permitted_params).to eq(expected_params)
        end
    end
  end
end
