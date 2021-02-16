# rubocop:disable Metrics/BlockLength
# rubocop:disable Performance/CollectionLiteralInLoop
namespace :consolidate_feedback_tables do
  desc "Copy data from old feedback tables into one table \
        and send old feedback data to BigQuery as Events"
  task consolidate_feedback_tables: :environment do
    def anonymised_attributes
      FeedbackEventConcerns::ANONYMISED_ATTRIBUTES
    end

    def trigger_event(feedback)
      # Based on FeedbackEventConcerns#trigger_feedback_provided_event

      feedback_data = feedback.attributes.map.each { |key, value|
        next if value.blank? || %w[id updated_at].include?(key) # updated_at will be the time this task is run

        if anonymised_attributes.include?(key.to_sym)
          [anonymised_attributes[key.to_sym], StringAnonymiser.new(value)]
        else
          [key, value]
        end
      }.compact.to_h

      Event.new.trigger(:feedback_provided, feedback_data)
    end

    AccountFeedback.find_each(batch_size: 100) do |account_feedback|
      feedback = Feedback.find_or_create_by(
        feedback_type: "jobseeker_account",
        created_at: account_feedback.created_at,
        rating: account_feedback.rating,
        jobseeker_id: account_feedback.jobseeker_id,
        comment: account_feedback.suggestions,
      )
      trigger_event(feedback)
    end

    GeneralFeedback.find_each(batch_size: 100) do |general_feedback|
      user_participation_response = if general_feedback.not_interested?
                                      "uninterested"
                                    else
                                      general_feedback.user_participation_response
                                    end

      feedback = Feedback.find_or_create_by(
        feedback_type: "general",
        created_at: general_feedback.created_at,
        comment: general_feedback.comment,
        visit_purpose: general_feedback.visit_purpose,
        visit_purpose_comment: general_feedback.visit_purpose_comment,
        email: general_feedback.email,
        user_participation_response: user_participation_response,
        recaptcha_score: general_feedback.recaptcha_score,
      )
      trigger_event(feedback)
    end

    # Convert a low-double-digits number of existing Feedback records to events because
    # many of them will have failed to export due to the BigQuery array error dealt with in this commit.
    # Choose not to worry about very low numbers of duplicates in analytics.
    Feedback.where(feedback_type: "job_alert").find_each(batch_size: 100) do |job_alert_feedback|
      trigger_event(job_alert_feedback)
    end

    JobAlertFeedback.find_each(batch_size: 100) do |job_alert_feedback|
      feedback = Feedback.find_or_create_by(
        feedback_type: "job_alert",
        created_at: job_alert_feedback.created_at,
        relevant_to_user: job_alert_feedback.relevant_to_user,
        comment: job_alert_feedback.comment,
        search_criteria: job_alert_feedback.search_criteria,
        job_alert_vacancy_ids: job_alert_feedback.vacancy_ids,
        subscription_id: job_alert_feedback.subscription_id,
        recaptcha_score: job_alert_feedback.recaptcha_score,
      )
      trigger_event(feedback)
    end

    UnsubscribeFeedback.find_each(batch_size: 100) do |unsubscribe_feedback|
      feedback = Feedback.find_or_create_by(
        feedback_type: "unsubscribe",
        created_at: unsubscribe_feedback.created_at,
        unsubscribe_reason: unsubscribe_feedback.reason,
        other_unsubscribe_reason_comment: unsubscribe_feedback.other_reason,
        comment: unsubscribe_feedback.additional_info,
        subscription_id: unsubscribe_feedback.subscription_id,
      )
      trigger_event(feedback)
    end

    VacancyPublishFeedback.find_each(batch_size: 100) do |vacancy_publish_feedback|
      user_participation_response = if vacancy_publish_feedback.not_interested?
                                      "uninterested"
                                    else
                                      vacancy_publish_feedback.user_participation_response
                                    end

      feedback = Feedback.find_or_create_by(
        feedback_type: "vacancy_publisher",
        created_at: vacancy_publish_feedback.created_at,
        vacancy_id: vacancy_publish_feedback.vacancy_id,
        publisher_id: vacancy_publish_feedback.publisher_id,
        comment: vacancy_publish_feedback.comment,
        email: vacancy_publish_feedback.email,
        user_participation_response: user_participation_response,
      )
      trigger_event(feedback)
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Performance/CollectionLiteralInLoop
