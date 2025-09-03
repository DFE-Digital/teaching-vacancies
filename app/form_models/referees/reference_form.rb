# frozen_string_literal: true

module Referees
  class ReferenceForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :token

    class << self
      def unstorable_fields
        []
      end

      def fields
        unstorable_fields + storable_fields
      end
    end

    def params_to_save
      attributes.symbolize_keys.slice(*self.class.storable_fields)
    end
  end
end
