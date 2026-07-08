class User < ApplicationRecord
  has_many :orders
  has_secure_password

  enum :role, { customer: "customer", admin: "admin" }, default: :customer

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
