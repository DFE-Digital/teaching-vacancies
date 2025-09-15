module PageObjects
  module Pages
    module Publisher
      module Ats
        class InterviewDateField < SitePrism::Section
          def self.selector(field)
            %(input[name="publishers_job_application_interview_datetime_form[#{field}]"])
          end

          element :day, selector("interview_date(3i)")
          element :month, selector("interview_date(2i)")
          element :year, selector("interview_date(1i)")
        end

        class InterviewDatetimePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"

          element :page_title, "h1"

          element :btn_submit, "#main-content .govuk-button-group button"
          element :btn_cancel, "#main-content .govuk-button-group .govuk-button--secondary"

          section :interview_date, InterviewDateField, ".govuk-date-input"
          element :interview_time, "#publishers-job-application-interview-datetime-form-interview-time-field"

          def set_interview_datetime(datetime)
            interview_date.day.set(datetime.day)
            interview_date.month.set(datetime.month)
            interview_date.year.set(datetime.year)
            interview_time.set(datetime.to_fs(:time_only))
          end

          def fill_and_submit(datetime)
            set_interview_datetime(datetime)
            btn_submit.click
          end
        end
      end
    end
  end
end
