require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:order_items) }
  end
  describe 'validations' do
    subject { FactoryBot.build(:order) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending processing shipped delivered cancelled]) }

    it 'always recalculates total from order_items, ignoring any directly assigned value' do
      order = FactoryBot.build(:order)
      order.total = -999
      order.valid?
      expect(order.total).not_to eq(-999)
    end
  end

  describe '#calculate_total' do
    let(:order) { FactoryBot.build(:order) }
    let(:product) { FactoryBot.build(:product, price: 10) }
    let(:order_item) { FactoryBot.create(:order_item, order: order, product: product, quantity: 3) }

    before do
      order.order_items << order_item
      order.calculate_total
    end

    it { expect(order.total).to eq(30) }
  end

  describe 'status transitions' do
    it 'always starts as pending, regardless of assigned status' do
      order = FactoryBot.build(:order, status: 'delivered')
      order.save
      expect(order.status).to eq('pending')
    end

    it 'allows a valid transition' do
      order = FactoryBot.create(:order)
      expect(order.update(status: 'processing')).to be true
      expect(order.reload.status).to eq('processing')
    end

    it 'rejects a transition that skips steps' do
      order = FactoryBot.create(:order)
      expect(order.update(status: 'delivered')).to be false
      expect(order.errors[:status]).to be_present
    end

    it 'rejects any transition out of a terminal state' do
      order = FactoryBot.create(:order)
      order.update!(status: 'processing')
      order.update!(status: 'shipped')
      order.update!(status: 'delivered')

      expect(order.update(status: 'cancelled')).to be false
    end
  end

  describe 'factory' do
    it 'is valid with valid attributes' do
      order = FactoryBot.build(:order)
      expect(order).to be_valid
    end
  end
end
