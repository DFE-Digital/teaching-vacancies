# frozen_string_literal: true

module Publishers
  module Vacancies
    class MakeDuplicateController < BaseController
      private

      def copy_vacancy(vacancy)
        CopyVacancy.new(vacancy).call.tap do |new_vacancy|
          if new_vacancy.include_additional_documents
            new_vacancy.supporting_documents.each do |document|
              send_dfe_analytics_event(:supporting_document_created, document.original_filename, document.size, document.content_type)
            end
          end

          if new_vacancy.application_form.present?
            document = new_vacancy.application_form.attachment
            send_dfe_analytics_event(:supporting_document_created, document.original_filename, document.size, document.content_type)
          end
        end
      end
    end
  end
end
