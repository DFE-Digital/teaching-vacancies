module Sections
  module SelfDisclosure
    class CommunicationHistorySection < SitePrism::Section
      element :heading, ".timeline-component__heading"

      elements :events, ".timeline-component__item"
    end
  end
end
