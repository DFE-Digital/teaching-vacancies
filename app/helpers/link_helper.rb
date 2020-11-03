module LinkHelper
  def active_link_class(link_path)
    return "govuk-header__navigation-item govuk-header__navigation-item--active" if current_page?(link_path)

    "govuk-header__navigation-item"
  end
end