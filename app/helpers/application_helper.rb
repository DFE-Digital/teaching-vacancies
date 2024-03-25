module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper

  def sanitize(text, options = {})
    super(text, options)&.gsub("&amp;", "&")
  end

  def body_class
    auth_class = publisher_signed_in? ? "publisher" : "jobseeker"
    action_class = "#{controller_path.tr('/', '_')}_#{action_name}"
    "govuk-template__body #{auth_class} #{action_class}"
  end

  def meta_description
    view = params[:id].presence || params[:action].presence
    controller_i18n_path = controller_path.tr("/", ".")

    if content_for :page_description
      content_for(:page_description).strip
    elsif I18n.exists?("#{controller_i18n_path}.#{view}.page_description")
      t("#{controller_i18n_path}.#{view}.page_description")
    else
      t("app.description")
    end
  end

  def footer_links
    [
      { text: "Cookies", href: cookies_preferences_path },
      { text: "Privacy policy", href: "https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/privacy-information-education-providers-workforce-including-teachers", attr: { target: "_blank" } },
      { text: "Terms and Conditions", href: page_path("terms-and-conditions") },
      { text: "Accessibility", href: page_path("accessibility") },
    ]
  end

  def include_google_tag_manager?
    cookies["consented-to-additional-cookies"] == "yes" && Rails.configuration.app_role.production?
  end
end
