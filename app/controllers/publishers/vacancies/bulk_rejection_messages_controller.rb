module Publishers
  module Vacancies
    class BulkRejectionMessagesController < BulkMessagesController
      def update
        ActiveRecord::Base.transaction do
          send_messages_for(@job_applications)

          @job_applications.each do |job_application|
            job_application.update!(status: :rejected)
          end
        end

        redirect_to_next next_step
      end

      def finish_wizard_path
        organisation_job_job_applications_path(vacancy.id, anchor: :unsuccessful)
      end
    end
  end
end
