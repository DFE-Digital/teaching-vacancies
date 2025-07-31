module Sections
  class TabsSection < SitePrism::Section
    elements :items, ".govuk-tabs__list a"
    element :panel, ".govuk-tabs__panel"

    def selected_tab
      items.detect { it["aria-selected"] == "true" }
    end

    def click_on(tab_id)
      items.detect { it["id"] == tab_id }.click
    end
  end
end
