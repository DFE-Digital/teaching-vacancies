module AbTestable
  extend ActiveSupport::Concern

  included do
    helper_method :ab_variant_for, :current_ab_variants, :current_variant?, :current_variant_container_name
  end

  def current_variant?(name_of_test, variant_name)
    ab_variant_for(name_of_test) == variant_name
  end

  def current_variant_container_name(name_of_test)
    "ab-test__#{name_of_test}--#{ab_variant_for(name_of_test)}"
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
