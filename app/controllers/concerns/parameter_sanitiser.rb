module ParameterSanitiser
  extend ActiveSupport::Concern

  def self.call(params = {})
    params.each_pair { |key, value| params[key] = Sanitize.fragment(value) }
  end
end
