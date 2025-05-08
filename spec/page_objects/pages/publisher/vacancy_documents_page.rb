# frozen_string_literal: true

module PageObjects
  module Pages
    module Publisher
      class VacancyDocumentsPage < CommonPage
        set_url "/organisation/jobs/{vacancy_id}/documents"

        element :add_another_document_yes_radio, "label[for='publishers-job-listing-documents-confirmation-form-upload-additional-document-true-field']"
        element :add_another_document_no_radio, "label[for='publishers-job-listing-documents-confirmation-form-upload-additional-document-false-field']"
      end
    end
  end
end
