# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class JobApplicationPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/job_applications/{job_application_id}"

        element :btn_update_status, ".govuk-button-group a.govuk-button.govuk-button--secondary"

        def update_status
          btn_update_status.click

          tag_page = PageObjects::Pages::Publisher::Ats::TagPage.new
          if tag_page.displayed?
            yield tag_page
          else
            raise "Tag page not displayed"
          end
        end
      end
    end
  end
end
