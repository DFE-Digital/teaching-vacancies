module Kernel
  ##
  # Wraps a block of code and rescues any errors that may occur if running in production, optionally
  # returning a default value. Allows us to gracefully degrade in situations where there's a risk of
  # errors occurring in non-critical code.
  #
  # @param default [Object] The default value to return on failure
  # @param error_klass [Exception] A specific error class to rescue from
  # @yieldreturn [Object] The value to return unless an error is raised
  # @return The result of the block (if no error is raised), or the value passed in as `default`
  def fail_safe(default = nil, error_klass = StandardError)
    yield
  rescue error_klass => e
    # Only rescue errors in production - when developing locally, it's normally desired to see
    # errors immediately
    raise e unless Rails.env.production?

    Rollbar.error(e)
    default
  end
end
