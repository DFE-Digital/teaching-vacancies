module Publishers
  module Vacancies
    class BulkRejectionMessagesController < BulkMessagesController
      def update
        if step == :send_messages
          super

          @job_applications.each do |job_application|
            job_application.update!(status: :rejected)
          end

        end
      end

      def finish_wizard_path
        organisation_job_job_applications_path(vacancy.id, anchor: :unsuccessful)
      end
    end
  end
end
