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

      VALID_TIME_FORMAT = /\A\d{1,2}(:\d{2})?\s*(am|pm)?\z/i

      private

      def cast_value(value)
        return value unless value.is_a?(::String) && value.match?(VALID_TIME_FORMAT)

        parsed_time = ::Time.zone.parse(value)
        return value if parsed_time.nil?

        parsed_time.extend(TimeInputField)
      rescue ArgumentError, TypeError
        value
      end
    end

    register(:time_or_string, TimeOrString)
  end
end
