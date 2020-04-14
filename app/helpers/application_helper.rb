module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper

  def sanitize(text, options = {})
    super(text, options)&.gsub('&amp;', '&')
  end

  def body_class
    auth_class = authenticated? ? 'hiring-staff' : ''
    action_class = controller_name + '_' + action_name
    "govuk-template__body app-body-class #{auth_class} #{action_class}"
  end

  def meta_description
    view = params[:id].presence || params[:action].presence
    controller_I18n_path = controller_path.gsub('/', '.')

    if content_for :page_description
      content_for(:page_description).strip
    elsif I18n.exists?("#{controller_I18n_path}.#{view}.page_description")
      t("#{controller_I18n_path}.#{view}.page_description")
    else
      t('app.description')
    end
  end
end
