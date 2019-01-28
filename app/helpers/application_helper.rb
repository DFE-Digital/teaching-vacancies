module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper

  def number_to_currency(number, options = {})
    super(number, options)
  end

  def sanitize(text, options = {})
    super(text, options)&.gsub('&amp;', '&')
  end

  def body_class
    auth_class = authenticated? ? 'hiring-staff' : ''
    action_class = controller_name + '_' + action_name
    "govuk-template__body app-body-class #{auth_class} #{action_class}"
  end
end
