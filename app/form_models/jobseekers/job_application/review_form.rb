module Jobseekers
  module JobApplication
    class ReviewForm < PreSubmitForm
      attr_accessor :confirm_data_accurate, :confirm_data_usage, :job_application

      validates_acceptance_of :confirm_data_accurate, :confirm_data_usage,
                              acceptance: true,
                              if: :all_steps_completed?
      # Files that are still awaiting an antivirus scan are allowed to progress through the wizard steps so the jobseeker can complete
      # the rest of their application while the scan runs. The uploaded_file_scan_safe is in this form
      # to ensure that the jobseeker cannot submit their application before the scan has run.
      validate :uploaded_file_scan_safe

      private

      def uploaded_file_scan_safe
        return unless job_application

        blob = if job_application.instance_of?(::UploadedJobApplication)
                 return unless job_application.application_form.attached?

                 job_application.application_form.blob
               else
                 return unless job_application.baptism_certificate.attached?

                 job_application.baptism_certificate.blob
               end

        return if blob.malware_scan_clean?

        message = if blob.malware_scan_pending?
                    I18n.t("jobs.file_pending_scan_message", filename: blob.filename)
                  else
                    I18n.t("jobs.file_unsafe_error_message", filename: blob.filename)
                  end
        errors.add(:base, message)
      end
    end
  end
end
