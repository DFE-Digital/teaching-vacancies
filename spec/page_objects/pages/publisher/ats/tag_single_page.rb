module PageObjects
  module Pages
    module Publisher
      module Ats
        class TagSinglePage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}/tag_single"

          element :form, "form"
          element :btn_save_and_continue, ".govuk-button.update-status"
          %w[submitted unsuccessful reviewed shortlisted interviewing].each do |status|
            element :"status_#{status}", "#publishers-job-application-status-form-status-#{status}-field", visible: false
          end

          def select_and_submit(status)
            public_send(:"status_#{status}").click
            btn_save_and_continue.click
          end
        end
      end
    end
  end
end
