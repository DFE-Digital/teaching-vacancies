# frozen_string_literal: true

class Publishers::MaliciousFileDetectedNotifier < Noticed::Event
  deliver_by :email, mailer: "Publishers::MalwareScanMailer", method: :malicious_file_detected
  required_param :filename, :publisher

  notification_methods do
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include DatesHelper

    def message
      t("notifications.publishers/malicious_file_detected_notification.message_html", filename: filename)
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
