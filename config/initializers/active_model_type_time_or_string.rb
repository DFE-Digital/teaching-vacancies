require_relative Rails.root.join("app/form_models/date_attribute_assignment")

module ActiveModel
  module Type
    class TimeOrString < ActiveModel::Type::Value
      module TimeInputField
        def to_s
          # this is to render only the time part in the form input
          to_fs(:time_only)
        end
      end

      private

      def cast_value(value)
        ::Time.zone.parse(value).extend(TimeInputField) || value
      rescue ArgumentError, TypeError
        value
      end
    end

    register(:time_or_string, TimeOrString)
  end
end
