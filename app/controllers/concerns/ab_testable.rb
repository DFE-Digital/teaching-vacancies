module AbTestable
  extend ActiveSupport::Concern

  included do
    helper_method :ab_variant_for, :current_ab_variants
  end

private

  def ab_variant_for(test)
    params.dig(:ab_test_override, test)&.to_sym || ab_tests.variant_for(test)
  end

  def current_ab_variants
    ab_tests.current_variants
  end

  def ab_tests
    @ab_tests ||= AbTests.new(session)
  end
end
