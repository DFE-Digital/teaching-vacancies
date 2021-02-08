module PageObjects
  class Home < SitePrism::Page
    class Facet < SitePrism::Section
      class FacetLink < SitePrism::Section; end

      sections :links, FacetLink, "a.govuk-link"

      def go_to(facet_text)
        links(text: facet_text).first.root_element.click
      end
    end

    set_url "/"

    element :search_button, ".govuk-button--start"
    section :cities, Facet, "div[data-facet-type='cities']"
    section :counties, Facet, "div[data-facet-type='counties']"
    section :subjects, Facet, "div[data-facet-type='subjects']"
    section :job_roles, Facet, "div[data-facet-type='job_roles']"

    def search
      search_button.click
    end
  end
end
