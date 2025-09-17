module PageObjects
  module Pages
    module Publisher
      module Ats
        class FeedbackDateField < SitePrism::Section
          def self.selector(field)
            %(input[name="publishers_job_application_feedback_form[#{field}]"])
          end

          element :day, selector("interview_feedback_received_at(3i)")
          element :month, selector("interview_feedback_received_at(2i)")
          element :year, selector("interview_feedback_received_at(1i)")
        end

        class FeedbackPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/update_tag"

          element :interview_feedback_received_yes, "#publishers-job-application-feedback-form-interview-feedback-received-true-field", visible: false
          element :interview_feedback_received_false, "#publishers-job-application-feedback-form-interview-feedback-received-false-field", visible: false
          section :interview_feedback_received_at, FeedbackDateField, ".govuk-date-input"
          element :btn_continue, "#main-content .govuk-button-group button"
          element :btn_cancel, "#main-content .govuk-button-group .govuk-button--secondary"

          def set_date(date)
            return unless date

            interview_feedback_received_at.day.set(date&.day)
            interview_feedback_received_at.month.set(date&.month)
            interview_feedback_received_at.year.set(date&.year)
          end

          def today
            interview_feedback_received_yes.click
            set_date(Time.zone.today)
            btn_continue.click
          end
        end

        class FeedbackTagPage < FeedbackPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"
        end
      end
    end
  end
end
