module Sections
  module SelfDisclosure
    class PersonalDetailsSection < SitePrism::Section
      def self.selector(index)
        %(div.govuk-summary-list__row:nth-child(#{index}) > dd:nth-child(2))
      end

      element :heading, "h2:nth-child(1)"

      element :name, selector(1)
      element :previous_names, selector(2)
      element :address_line_1, selector(3)
      element :address_line_2, selector(4)
      element :city, selector(5)
      element :country, selector(6)
      element :postcode, selector(7)
      element :phone_number, selector(8)
      element :date_of_birth, selector(9)
    end
  end
end
