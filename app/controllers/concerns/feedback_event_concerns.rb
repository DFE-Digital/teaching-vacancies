module FeedbackEventConcerns
  extend ActiveSupport::Concern

  ANONYMISE_THESE_PARAMS = %w[email jobseeker_id publisher_id subscription_id].freeze

  def trigger_feedback_provided_event
    feedback_data = feedback_attributes.to_h.each_with_object({}) do |(key, value), params|
      if ANONYMISE_THESE_PARAMS.include?(key.to_s)
        params["anonymised_#{key}"] = StringAnonymiser.new(value)
      else
        params[key] = value
      end
    end
    feedback_data[:recaptcha_score] = recaptcha_reply["score"] unless recaptcha_reply&.dig("score").blank?
    request_event.trigger(:feedback_provided, feedback_data)
  end
end
