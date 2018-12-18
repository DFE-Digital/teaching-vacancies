module ParameterSanitiser
  extend ActiveSupport::Concern

  def self.call(params = {})
    sanitised_params = params.each_pair do |key, value|
      params[key] = Sanitize.fragment(value)
    end
    ActionController::Parameters.new(sanitised_params)
  end
end
