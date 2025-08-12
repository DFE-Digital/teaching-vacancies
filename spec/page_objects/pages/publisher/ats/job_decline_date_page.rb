module PageObjects
  module Pages
    module Publisher
      module Ats
        class DeclineDateField < SitePrism::Section
          def self.selector(field)
            %(input[name="publishers_job_application_declined_form[#{field}]"])
          end

          element :day, selector("declined_at(3i)")
          element :month, selector("declined_at(2i)")
          element :year, selector("declined_at(1i)")
        end

        class JobDeclineDatePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"

          section :declined_at, DeclineDateField, ".govuk-date-input"
          element :btn_continue, "#main-content .govuk-button-group button"
          element :btn_cancel, "#main-content .govuk-button-group .govuk-button--secondary"

          def set_date(date)
            return unless date

            declined_at.day.set(date&.day)
            declined_at.month.set(date&.month)
            declined_at.year.set(date&.year)
          end

          def today
            set_date(Time.zone.today)
            btn_continue.click
          end
        end
      end
    end
  end
end
