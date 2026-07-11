# frozen_string_literal: true

module Types
  class OrderStatusType < Types::BaseEnum
    Order::STATUSES.each do |status|
      value status.upcase, value: status
    end
  end
end
