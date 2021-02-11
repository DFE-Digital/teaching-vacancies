module FeedbackEventConcerns
  extend ActiveSupport::Concern

  def trigger_feedback_provided_event
    anonymise_these_params = %w[jobseeker_id publisher_id]
    feedback_data = feedback_attributes.to_h.each_with_object({}) do |(key, value), params|
      if anonymise_these_params.include?(key)
        params["anonymised_#{key}"] = StringAnonymiser.new(value)
      else
        params[key] = value
      end
    end
    feedback_data[:recaptcha_score] = recaptcha_reply["score"] unless recaptcha_reply&.dig("score").blank?
    request_event.trigger(:feedback_provided, feedback_data)
  end
end
