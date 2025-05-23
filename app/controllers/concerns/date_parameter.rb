module DateParameter
  extend ActiveSupport::Concern

  # covered by spec/controllers/concerns/date_parameter_spec.rb
  # :nocov:
  class_methods do
    def date_param(method_name, **options)
      define_method(:"parse_#{method_name}") do
        *keys, field = Array(send(method_name))
        return if keys.empty?

        hash = params.dig(*keys)
        return if hash.blank?

        hash[field] = [
          hash.delete("#{field}(1i)"), # year
          hash.delete("#{field}(2i)"), # month
          hash.delete("#{field}(3i)"), # day
        ].join("-")
      end

      before_action(:"parse_#{method_name}", options)
    end
  end
  # :nocov:
end
