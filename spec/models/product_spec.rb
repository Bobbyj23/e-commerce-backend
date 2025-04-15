require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { should belong_to(:category) }
    itself { should have_many(:order_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'factory' do
    it 'is valid with valid attributes' do
      product = FactoryBot.build(:product)
      expect(product).to be_valid
    end
  end

  # describe 'price' do
  #   it 'saves correctly formatted prices' do
  #     product = FactoryBot.create(:product, price: 10.50)
  #     expect(product.price).to eq(10.50)
  #   end
  # end
end
