# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class IncludeAdditionalDocumentsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/build/include_additional_documents"

        element :include_documents_yes, "label[for='publishers-job-listing-include-additional-documents-form-include-additional-documents-true-field']"
      end
    end
  end
end
