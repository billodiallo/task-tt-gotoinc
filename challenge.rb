module ActiveModel
  module Validations
    module ClassMethods
      validates :username, presence: true
      validates :name, presence: true, allow_blank: false
      validates :age, inclusion: { in: 0..9 }
      validates :age, numericality: true
      validates :username, presence: true
      validates :first_name, length: { maximum: 30 }
      validates :password, presence: true, confirmation: true, if: :password_required?
      validates :token, length: 24, strict: TokenLengthException
      validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
      validates :owner, type: User
    end
  end
end
