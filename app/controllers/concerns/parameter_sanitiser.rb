module ParameterSanitiser
  extend ActiveSupport::Concern

  def self.call(params = {})
    sanitize_nested_params(params)
  end

  def self.sanitize_params_value(value)
    case value
    when ActionController::Parameters
      sanitize_nested_params(value)
    when Array
      value.map { |v| Sanitize.fragment(v) }
    else
      Sanitize.fragment(value)
    end
  end

  def self.sanitize_nested_params(parameters)
    parameters.each_pair { |key, value| parameters[key] = sanitize_params_value(value) }
  end
end
