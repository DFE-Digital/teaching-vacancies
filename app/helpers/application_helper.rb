module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper

  def number_to_currency(number, options = {})
    super(number, options)
  end

  def sanitize(text, options = {})
    super(text, options)&.gsub('&amp;', '&')
  end
end
