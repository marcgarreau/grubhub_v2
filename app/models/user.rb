class User<ActiveRecord::Base
  has_secure_password

  validates :first_name,            presence: true
  validates :last_name,             presence: true
  validates :email,                 presence: true
  validates :password_confirmation, presence: true
  validates :email,                 uniqueness: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :nickname,
    length: { minimum: 2, maximum: 32 }, allow_blank: true

  has_many :addresses
  has_many :orders
end
