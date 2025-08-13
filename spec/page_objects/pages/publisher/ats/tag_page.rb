module PageObjects
  module Pages
    module Publisher
      module Ats
        class TagPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"

          element :form, "form"
          element :btn_save_and_continue, ".govuk-button.update-status"
          %w[submitted unsuccessful reviewed shortlisted interviewing offered].each do |status|
            element :"status_#{status}", "#publishers-job-application-tag-form-status-#{status}-field", visible: false
          end

          def select_and_submit(status)
            public_send(:"status_#{status}").click
            btn_save_and_continue.click

            if status == "offered" && block_given?
              job_offer_date_page = PageObjects::Pages::Publisher::Ats::JobOfferDatePage.new
              yield job_offer_date_page if job_offer_date_page.displayed?
            end
          end
        end
      end
    end
  end
end
