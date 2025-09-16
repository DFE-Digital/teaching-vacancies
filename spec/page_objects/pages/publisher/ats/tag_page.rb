module PageObjects
  module Pages
    module Publisher
      module Ats
        class TagPage < CommonPage
          set_url "/organisation/jobs/{vacancy_id}/job_applications/tag{?query*}"

          element :form, "form"
          element :btn_save_and_continue, ".govuk-button.update-status"
          %w[submitted unsuccessful reviewed shortlisted interviewing offered unsuccessful-interview].each do |status|
            element :"status_#{status.tr('-', '_')}", "#publishers-job-application-tag-form-status-#{status}-field", visible: false
          end

          def select_and_submit(status)
            public_send(:"status_#{status.tr('-', '_')}").click
            btn_save_and_continue.click

            if status == "interviewing" && block_given?
              ref_and_dis_page = PageObjects::Pages::Publisher::Ats::ReferenceAndSelfDisclosurePage.new
              yield ref_and_dis_page if ref_and_dis_page.displayed?
            end

            if status == "unsuccessful_interview" && block_given?
              feedback_page = PageObjects::Pages::Publisher::Ats::FeedbackPage.new
              yield feedback_page if feedback_page.displayed?
            end

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
