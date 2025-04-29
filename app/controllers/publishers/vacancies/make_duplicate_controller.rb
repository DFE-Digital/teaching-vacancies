# frozen_string_literal: true

module Publishers
  module Vacancies
    class MakeDuplicateController < BaseController
      private

      def copy_vacancy(vacancy)
        CopyVacancy.new(vacancy).call.tap do |new_vacancy|
          if new_vacancy.include_additional_documents
            new_vacancy.supporting_documents.attachments.each do |document|
              send_dfe_analytics_event(:supporting_document_created, new_vacancy.id, document.blob)
            end
          end

          if new_vacancy.application_form.present?
            send_dfe_analytics_event(:supporting_document_created, new_vacancy.id, new_vacancy.application_form.attachment.blob)
          end
        end
      end

      def send_dfe_analytics_event(event_type, vacancy_id, blob)
        fail_safe do
          event = DfE::Analytics::Event.new
                                       .with_type(event_type)
                                       .with_request_details(request)
                                       .with_response_details(response)
                                       .with_user(current_publisher)
                                       .with_data(data: {
                                         vacancy_id: vacancy_id,
                                         document_type: "supporting_document",
                                         name: blob.filename,
                                         size: blob.byte_size,
                                         content_type: blob.content_type,
                                       })

          DfE::Analytics::SendEvents.do([event])
        end
      end
    end
  end
end
