require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before { request.headers.merge! headers }

  def graphql_data
    JSON.parse(response.body)
  end

  describe 'products query' do
    let!(:category) { FactoryBot.create(:category) }
    let!(:product) { FactoryBot.create(:product, category: category) }

    it 'returns products for an authenticated user' do
      post :execute, params: { query: '{ products { id name } }' }

      expect(response).to have_http_status(:ok)
      expect(graphql_data['data']['products'].map { |p| p['id'] }).to contain_exactly(product.id.to_s)
    end

    it 'returns unauthorized with no Authorization header' do
      request.headers['Authorization'] = nil
      post :execute, params: { query: '{ products { id name } }' }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'orders query' do
    let!(:own_order) { FactoryBot.create(:order, user: user) }
    let!(:other_order) { FactoryBot.create(:order) }

    it 'only returns the current user\'s orders' do
      post :execute, params: { query: '{ orders { id } }' }

      ids = graphql_data['data']['orders'].map { |o| o['id'] }
      expect(ids).to contain_exactly(own_order.id.to_s)
      expect(ids).not_to include(other_order.id.to_s)
    end
  end

  describe 'updateOrderStatus mutation' do
    let!(:order) { FactoryBot.create(:order, user: user) }

    let(:mutation) do
      <<~GQL
        mutation($orderId: ID!, $status: OrderStatus!) {
          updateOrderStatus(input: { orderId: $orderId, status: $status }) {
            order { id status }
            errors
          }
        }
      GQL
    end

    it 'applies a valid transition and reuses the model state machine' do
      post :execute, params: { query: mutation, variables: { orderId: order.id, status: 'PROCESSING' } }

      result = graphql_data['data']['updateOrderStatus']
      expect(result['errors']).to eq([])
      expect(result['order']['status']).to eq('PROCESSING')
      expect(order.reload.status).to eq('processing')
    end

    it 'rejects an invalid transition through the payload errors, not an exception' do
      post :execute, params: { query: mutation, variables: { orderId: order.id, status: 'DELIVERED' } }

      result = graphql_data['data']['updateOrderStatus']
      expect(result['order']).to be_nil
      expect(result['errors']).to include(match(/cannot transition/))
      expect(order.reload.status).to eq('pending')
    end

    it "returns a schema-level error for another user's order instead of leaking it" do
      other_order = FactoryBot.create(:order)
      post :execute, params: { query: mutation, variables: { orderId: other_order.id, status: 'PROCESSING' } }

      expect(graphql_data['errors'].first['message']).to eq('Record not found')
    end
  end
end
