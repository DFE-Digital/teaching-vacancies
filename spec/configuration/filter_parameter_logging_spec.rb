require "rails_helper"

RSpec.describe "Filter parameter logging configuration" do
  let(:analytics_hidden_pii) { Rails.application.config_for(:analytics_hidden_pii) }
  let(:filter_params) { Rails.application.config.filter_parameters }

  specify "all anonymised analytics fields should be filtered from logs" do
    analytics_hidden_pii.each_value do |shared|
      shared.each do |field|
        matched = filter_params.any? do |pattern|
          pattern.is_a?(Regexp) ? pattern.match?(field.to_s) : pattern == field.to_sym
        end
        expect(matched).to be(true), "Expected #{field} to be included in filter parameters"
      end
    end
  end
end
