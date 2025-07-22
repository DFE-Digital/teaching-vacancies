module Sections
  class NavSection < SitePrism::Section
    elements :items, ".tabs-component-navigation__item a"

    def click_on(nav_item)
      items.detect { it.text == nav_item }.click
    end

    def current_item
      items.detect { it["aria-current"] == "page" }
    end
  end
end
