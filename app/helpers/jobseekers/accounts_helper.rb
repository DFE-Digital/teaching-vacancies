module Jobseekers::AccountsHelper
  def account_navigation_link(link_text, link_path)
    govuk_link_to link_text, link_path, class: "tabs-component-navigation__link", aria: { current: ("page" if current_page?(link_path)) }
  end
end
