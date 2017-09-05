module ApplicationHelper
  include ActionView::Helpers::NumberHelper

  def number_to_currency(number, options = {})
    options[:locale] ||= I18n.locale
    options[:precision] = 0
    super(number, options)
  end
end
