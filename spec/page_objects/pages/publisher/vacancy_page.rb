# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class VacancyPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}"

        element :change_additional_documents_link, "#include_additional_documents a"

        element :change_job_title_link, "#job_title a"
        element :change_salary_link, "#salary a"
        element :change_expires_at_link, "#expires_at a"
        element :change_publish_on_link, "#publish_on a"
        element :change_application_form_link, "#application_form .govuk-summary-list__actions a"
        element :change_supporting_documents_link, "#supporting_documents .govuk-summary-list__actions a"
      end
    end
  end
end
