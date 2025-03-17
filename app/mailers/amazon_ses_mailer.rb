# frozen_string_literal: true

# rubocop:disable Rails/ApplicationMailer
class AmazonSesMailer < ActionMailer::Base
  include MailerAnalyticsEvents
  helper NotifyViewsHelper

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  # :nocov:
  self.delivery_method = :smtp unless Rails.env.test?
  # :nocov:

  default from: "ats.teachingvacancies@service.education.gov.uk"

  def send_email(to:, subject:)
    @to = to
    mail(to: to, subject: subject, delivery_method_options: {
      user_name: Rails.application.credentials.dig(:smtp, :user_name),
      password: Rails.application.credentials.dig(:smtp, :password),
      address: "email-smtp.eu-west-2.amazonaws.com",
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
# rubocop:enable Rails/ApplicationMailer
