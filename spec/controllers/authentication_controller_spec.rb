require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe '#login' do
    let(:username) { 'test_user' }
    let(:password) { 'password123' }

    context 'when user is not found' do
      before do
        allow(User).to receive(:find_by).with(username: username).and_return(nil)
        post :login, params: { username: username, password: password }
      end

      it 'returns a not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a user not found error message' do
        expect(JSON.parse(response.body)['error']).to eq('User Not Found')
      end
    end

    context 'when user is found but authentication fails' do
      let!(:user) { FactoryBot.create(:user, username: username, password: 'wrong_password', password_confirmation: 'wrong_password') }

      before do
        allow(User).to receive(:find_by).with(username: username).and_return(user)
        post :login, params: { username: username, password: password }
      end

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an unauthorized error message' do
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'when user is found and authentication succeeds' do
      let!(:user) { FactoryBot.create(:user, username: username, password: password, password_confirmation: password) }

      before do
        allow(User).to receive(:find_by).with(username: username).and_return(user)
        post :login, params: { username: username, password: password }
      end

      it 'returns an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a token' do
        expect(JSON.parse(response.body)['token']).to be_present
      end
    end

    context 'when KeyError is raised' do
      before do
        allow(User).to receive(:find_by).with(username: username).and_raise(KeyError)
        post :login, params: { username: username, password: password }
      end

      it 'returns a bad request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a bad request error message' do
        expect(JSON.parse(response.body)['error']).to start_with('Bad Request:')
      end
    end

    context 'when JWT::EncodeError is raised' do
      before do
        allow(User).to receive(:find_by).with(username: username).and_return(FactoryBot.create(:user, username: username, password: password, password_confirmation: password))
        allow_any_instance_of(AuthenticationController).to receive(:jwt_encode).and_raise(JWT::EncodeError)
        post :login, params: { username: username, password: password }
      end

      it 'returns an internal server error status' do
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns a token generation failed error message' do
        expect(JSON.parse(response.body)['error']).to start_with('Token Generation Failed:')
      end
    end

    context 'when StandardError is raised' do
      before do
        allow(User).to receive(:find_by).with(username: username).and_raise(StandardError)
        post :login, params: { username: username, password: password }
      end

      it 'returns an internal server error status' do
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns an internal server error message' do
        expect(JSON.parse(response.body)['error']).to start_with('Internal Server Error:')
      end
    end
  end
end
