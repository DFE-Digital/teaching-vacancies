module Jobseekers::AccountsHelper
  def account_navigation_link(link_text, link_path)
    link_to link_text, link_path, class: "dashboard-component-navigation__link", aria: { current: ("page" if current_page?(link_path)) }
  end
end
