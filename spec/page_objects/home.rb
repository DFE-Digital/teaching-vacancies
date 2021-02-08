module PageObjects
  class Home < SitePrism::Page
    set_url "/"

    element :search_button, ".govuk-button--start"

    def search
      search_button.click
    end
  end
end
