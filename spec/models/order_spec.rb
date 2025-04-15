require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:order_items) }
  end
  describe 'validations' do
    subject { FactoryBot.build(:order) }
    it { is_expected.to validate_presence_of(:total) }
    it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending processing shipped delivered cancelled]) }
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

  describe 'factory' do
    it 'is valid with valid attributes' do
      order = FactoryBot.build(:order)
      expect(order).to be_valid
    end
  end
end
