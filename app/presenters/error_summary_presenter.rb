class ErrorSummaryPresenter
  def initialize(errors, link_generator = ->(_) {})
    @errors = errors
    @link_generator = link_generator
  end

  def formatted_error_messages
    @errors.map do |error|
      [
        error.attribute,
        error.message,
        @link_generator.call(error).presence || "##{error.attribute}",
      ]
    end
  end
end
