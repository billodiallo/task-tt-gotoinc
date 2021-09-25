module ActiveModel
    module Validations
      module ClassMethods

        validates :username, presence: true
        validates :name, presence: true, allow_blank: false
        validates :age, inclusion: { in: 0..9 }

      end
    end
end
