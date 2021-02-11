require "page_objects/search/filters"

module PageObjects
  module Vacancy
    class Index < SitePrism::Page
      class VacancyRow < SitePrism::Section
        element :link, ".view-vacancy-link"

        def job_title
          link.text
        end
      end

      class Pagination < SitePrism::Section
        class PaginationLink < SitePrism::Section; end

        sections :links, PaginationLink, ".pagination__item"

        def go_to(page_text)
          links(text: page_text).first.root_element.click
        end
      end

      set_url "/jobs"
      set_url_matcher(/jobs/)

      element :search_button, ".govuk-button"
      element :sort_field, "#jobs-sort-field"
      element :stats, "#vacancies-stats-top"
      section :filters, PageObjects::Search::Filters, ".filters-form"
      section :pagination, Pagination, "ul.pagination"
      sections :jobs, VacancyRow, "li.vacancy"

      def search
        search_button.click
      end
    end
  end
end
