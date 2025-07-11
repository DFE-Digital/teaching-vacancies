module Sections
  class QuickLinksSection < SitePrism::Section
    elements :items, ".navigation-list-component__anchor a"
  end
end
