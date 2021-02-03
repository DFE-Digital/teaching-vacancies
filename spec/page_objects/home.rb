module PageObjects
  class Home < SitePrism::Page
    class FacetSection < SitePrism::Section
      class Facet < SitePrism::Section
        element :link, "a"

        def visit
          link.click
        end
      end

      sections :facets, Facet, "li"
    end

    set_url "/"

    element :search_button, ".govuk-button--start"
    section :cities, FacetSection, "div[data-facet-type='cities']"
    section :counties, FacetSection, "div[data-facet-type='counties']"
    section :subjects, FacetSection, "div[data-facet-type='subjects']"
    section :job_roles, FacetSection, "div[data-facet-type='job_roles']"

    def search
      search_button.click
    end
  end
end
