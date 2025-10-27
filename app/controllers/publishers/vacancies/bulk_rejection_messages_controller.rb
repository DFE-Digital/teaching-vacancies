module Publishers
  module Vacancies
    class BulkRejectionMessagesController < BulkMessagesController
      def send_rejection_emails
        send_messages_for(@job_applications)

        @job_applications.each do |job_application|
          job_application.update!(status: :rejected)
        end

        redirect_to organisation_job_job_applications_path(vacancy.id, anchor: :unsuccessful), success: t(".rejections_sent")
      end
    end
  end
end
