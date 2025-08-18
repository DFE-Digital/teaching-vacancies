# frozen_string_literal: true

# rubocop:disable Rails/ApplicationMailer
# :nocov:
class AmazonSesMailer < ActionMailer::Base
  include MailerAnalyticsEvents

  helper NotifyViewsHelper

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  self.delivery_method = :smtp unless Rails.env.test?

  default from: "ats.teachingvacancies@service.education.gov.uk"

  def send_email(to:, subject:)
    @to = to
    mail(to: to, subject: subject, delivery_method_options: {
      user_name: ENV.fetch("SMTP_USERNAME", nil),
      password: ENV.fetch("SMTP_PASSWORD", nil),
      address: "email-smtp.eu-west-2.amazonaws.com",
      port: 587,
    }) do |format|
      format.text
      # format.html
    end
  end

  private

  attr_reader :to

  def template
    NOTIFY_PRODUCTION_TEMPLATE
  end
end
# :nocov:
# rubocop:enable Rails/ApplicationMailer
