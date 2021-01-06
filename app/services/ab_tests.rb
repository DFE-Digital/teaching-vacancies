# Selects and persists AB test variants in the Rails session
class AbTests
  SESSION_KEY = :ab_tests

  # Creates a new instance for a given Rails session, with an option to override the default
  # configuration
  def initialize(session, test_configuration: Rails.configuration.ab_tests)
    @session = session
    @test_configuration = test_configuration

    session[SESSION_KEY] ||= {}
  end

  # Returns the selected variant for a given test
  def variant_for(test)
    raise ArgumentError, "AB test '#{test}' is not configured" unless available_ab_tests.include?(test)
    return session[SESSION_KEY][test] if session[SESSION_KEY][test]

    candidates = test_configuration[test].flat_map { |variant_name, weight| [variant_name] * weight }

    session[SESSION_KEY][test] = candidates.sample
  end

  # Returns a hash of all tests mapped to their selected variants
  def current_variants
    available_ab_tests.to_h { |test| [test, variant_for(test)] }
  end

private

  attr_reader :session, :test_configuration

  def available_ab_tests
    test_configuration.keys
  end
end
