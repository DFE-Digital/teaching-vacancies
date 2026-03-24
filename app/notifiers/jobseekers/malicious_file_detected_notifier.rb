# frozen_string_literal: true

class Jobseekers::MaliciousFileDetectedNotifier < Noticed::Event
  deliver_by :email, mailer: "Jobseekers::MalwareScanMailer", method: :malicious_file_detected
  required_param :filename, :jobseeker

  notification_methods do
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include DatesHelper

    def message
      t("notifications.jobseekers/malicious_file_detected_notification.message_html", filename: filename)
    end

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private

    def filename
      params[:filename]
    end
  end
end
