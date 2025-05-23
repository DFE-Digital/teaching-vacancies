module Sections
  module SelfDisclosure
    class FormSection < SitePrism::Section
      element :heading, "h2:nth-child(1)"
    end
  end
end
