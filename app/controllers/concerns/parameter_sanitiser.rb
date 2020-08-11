module ParameterSanitiser
  extend ActiveSupport::Concern

  def self.call(params = {})
    params.each_pair { |key, value|
      if value.is_a?(ActionController::Parameters)
        params[key] = sanitize_nested_params(value)
      else
        params[key] = Sanitize.fragment(value)
      end
    }
  end

  private

  def self.sanitize_nested_params(parameters)
    parameters.each_pair { |key, value| parameters[key] = Sanitize.fragment(value) }
  end
end
