module ActiveModel
  module Validations
    module ClassMethods
      validates :username, presence: true
      validates :name, presence: true, allow_blank: true
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

  # Add custom validation for User

  class User
    include ActiveModel::Validations
    attr_accessor :name, :email

    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, email: true
  end

  # Add  custom email validation class and method

  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, (options[:message] || 'is not an email') unless
        /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(value)
    end
  end

  def validates(*attributes)
    defaults = attributes.extract_options!.dup
    validations = defaults.slice!(*_validates_default_keys)

    raise ArgumentError, 'You need to supply at least one attribute' if attributes.empty?
    raise ArgumentError, 'You need to supply at least one validation' if validations.empty?

    defaults[:attributes] = attributes

    validations.each do |key, options|
      key = "#{key.to_s.camelize}Validator"

      begin
        validator = key.include?('::') ? key.constantize : const_get(key)
      rescue NameError
        raise ArgumentError, "Unknown validator: '#{key}'"
      end

      next unless options

      validates_with(validator, defaults.merge(_parse_validates_options(options)))
    end
  end

  class Person
    include ActiveModel::Validations

    attr_accessor :name

    validates! :name, presence: true
  end

  person = Person.new
  person.name = ''
  person.valid?

  # => ActiveModel::StrictValidationFailed: Name can't be blank

  def validates!(*attributes)
    options = attributes.extract_options!
    options[:strict] = true
    validates(*(attributes << options))
  end

  private

  # When creating custom validators, it might be useful to be able to specify
  # additional default keys. This can be done by overwriting this method.
  def _validates_default_keys
    %i[if unless on allow_blank allow_nil strict]
  end

  def _parse_validates_options(options)
    case options
    when TrueClass
      {}
    when Hash
      options
    when Range, Array
      { in: options }
    else
      { with: options }
    end
  end
end
