module TabsHelper
  def tab_item(link_text, link_path, active: false)
    active = true if current_page?(link_path)
    govuk_link_to link_text, link_path, class: "tabs-component-navigation__link", aria: { current: ("page" if active) }
  end
end
