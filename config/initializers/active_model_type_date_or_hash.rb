require_relative Rails.root.join("app/form_models/date_attribute_assignment")

module ActiveModel
  module Type
    class DateOrHash < ActiveModel::Type::Value
      include DateAttributeAssignment

      private

      def cast_value(value)
        date_from_multiparameter_hash(value)
      end
    end

    register(:date_or_hash, DateOrHash)
  end
end
