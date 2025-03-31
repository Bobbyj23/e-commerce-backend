require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should have_many(:products) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  # describe 'factory' do
  #   it 'is valid with valid attributes' do
  #     category = FactoryBot.build(:category)
  #     expect(category).to be_valid
  #   end
  # end
end
