module FeedbackEventConcerns
  extend ActiveSupport::Concern

  ANONYMISED_ATTRIBUTES = {
    application_id: "application_identifier",
    email: "email_identifier",
    jobseeker_id: "jobseeker_identifier",
    publisher_id: "publisher_identifier",
    subscription_id: "subscription_identifier",
  }.freeze

  def trigger_feedback_provided_event
    feedback_data = feedback_attributes.to_h.each_with_object({}) do |(key, value), attributes|
      if ANONYMISED_ATTRIBUTES.include?(key.to_sym)
        attributes[ANONYMISED_ATTRIBUTES[key.to_sym]] = StringAnonymiser.new(value)
      else
        attributes[key] = value
      end
    end
    feedback_data[:recaptcha_score] = recaptcha_reply["score"] unless recaptcha_reply&.dig("score").blank?
    request_event.trigger(:feedback_provided, feedback_data)
  end
end
