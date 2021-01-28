namespace :consolidate_feedback_tables do
  desc "Copy data from feedback tables into one table"
  task consolidate_feedback_tables: :environment do
    AccountFeedback.all.in_batches(of: 100).each_record do |account_feedback|
      Feedback.create(
        feedback_type: "jobseeker_account",
        created_at: account_feedback.created_at,
        rating: account_feedback.rating,
        jobseeker_id: account_feedback.jobseeker_id,
        comment: account_feedback.suggestions,
      )
    end

    GeneralFeedback.all.in_batches(of: 100).each_record do |general_feedback|
      user_participation_response = if general_feedback.not_interested?
                                      "uninterested"
                                    else
                                      general_feedback.user_participation_response
                                    end

      Feedback.create(
        feedback_type: "general",
        created_at: general_feedback.created_at,
        comment: general_feedback.comment,
        visit_purpose: general_feedback.visit_purpose,
        visit_purpose_comment: general_feedback.visit_purpose_comment,
        email: general_feedback.email,
        user_participation_response: user_participation_response,
        recaptcha_score: general_feedback.recaptcha_score,
      )
    end

    JobAlertFeedback.all.in_batches(of: 100).each_record do |job_alert_feedback|
      Feedback.create(
        feedback_type: "job_alert",
        created_at: job_alert_feedback.created_at,
        relevant_to_user: job_alert_feedback.relevant_to_user,
        comment: job_alert_feedback.comment,
        search_criteria: job_alert_feedback.search_criteria,
        job_alert_vacancy_ids: job_alert_feedback.vacancy_ids,
        subscription_id: job_alert_feedback.subscription_id,
        recaptcha_score: job_alert_feedback.recaptcha_score,
      )
    end

    UnsubscribeFeedback.all.in_batches(of: 100).each_record do |unsubscribe_feedback|
      Feedback.create(
        feedback_type: "unsubscribe",
        created_at: unsubscribe_feedback.created_at,
        unsubscribe_reason: unsubscribe_feedback.reason,
        other_unsubscribe_reason_comment: unsubscribe_feedback.other_reason,
        comment: unsubscribe_feedback.additional_info,
        subscription_id: unsubscribe_feedback.subscription_id,
      )
    end

    VacancyPublishFeedback.all.in_batches(of: 100).each_record do |vacancy_publish_feedback|
      user_participation_response = if vacancy_publish_feedback.not_interested?
                                      "uninterested"
                                    else
                                      vacancy_publish_feedback.user_participation_response
                                    end

      Feedback.create(
        feedback_type: "vacancy_publisher",
        created_at: vacancy_publish_feedback.created_at,
        vacancy_id: vacancy_publish_feedback.vacancy_id,
        publisher_id: vacancy_publish_feedback.publisher_id,
        comment: vacancy_publish_feedback.comment,
        email: vacancy_publish_feedback.email,
        user_participation_response: user_participation_response,
      )
    end
  end
end
