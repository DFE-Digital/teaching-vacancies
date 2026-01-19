module ComponentHelperDelegation
  extend ActiveSupport::Concern

  def method_missing(symbol, ...)
    return super if view_context.nil?

    if helpers.respond_to?(symbol)
      helpers.public_send(symbol, ...)
    else
      super
    end
  end

  def respond_to_missing?(symbol, include_private = false)
    return super if view_context.nil?

    helpers.respond_to?(symbol, include_private) || super
  end
end
