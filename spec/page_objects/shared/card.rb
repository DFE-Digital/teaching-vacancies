module PageObjects
  module Shared
    class Card < SitePrism::Section
      element :header, ".card-component__header"
      element :body, ".card-component__body"
      section :actions, ".card-component__actions" do
        elements :inputs, "input[type='submit']"
        elements :links, "a.govuk-link"
      end
    end
  end
end
