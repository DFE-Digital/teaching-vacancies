module PageObjects
  module Pages
    module Publisher
      module Ats
        class OfferDateField < SitePrism::Section
          def self.selector(field)
            %(input[name="publishers_job_application_offered_form[#{field}]"])
          end

          element :day, selector("offered_at(3i)")
          element :month, selector("offered_at(2i)")
          element :year, selector("offered_at(1i)")
        end

        class JobOfferDatePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/update_tag"

          section :offered_at, OfferDateField, ".govuk-date-input"
          element :btn_continue, "#main-content .govuk-button-group button"
          element :btn_cancel, "#main-content .govuk-button-group .govuk-button--secondary"

          def set_date(date)
            return unless date

            offered_at.day.set(date&.day)
            offered_at.month.set(date&.month)
            offered_at.year.set(date&.year)
          end

          def one_day_ago
            set_date(1.day.ago)
            btn_continue.click
          end
        end

        class JobOfferDateTagPage < JobOfferDatePage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"
        end
      end
    end
  end
end
