# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class IncludeAdditionalDocumentsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/include_additional_documents"

        element :include_documents_yes, "label[for='publishers-job-listing-include-additional-documents-form-include-additional-documents-true-field']"

        def fill_in_and_submit_form(include_additional_documents)
          choose I18n.t("helpers.label.publishers_job_listing_include_additional_documents_form.include_additional_documents_options.#{include_additional_documents}")

          click_on I18n.t("buttons.save_and_continue")
        end
      end
    end
  end
end
