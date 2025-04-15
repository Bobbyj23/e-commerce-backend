require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end
  describe 'validations' do
    subject { FactoryBot.build(:order_item) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
  end

  describe 'callbacks' do
    let(:product) { FactoryBot.create(:product, price: 20) }
    let(:order_item) { FactoryBot.create(:order_item, product: product) }

    it 'sets the price before validation' do
      byebug
      order_item.valid?
      expect(order_item.price).to eq(product.price)
    end
  end
end
