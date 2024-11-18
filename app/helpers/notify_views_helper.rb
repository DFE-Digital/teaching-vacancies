module NotifyViewsHelper
  def notify_mail_to(mail_to, text = mail_to)
    notify_link("mailto:#{mail_to}", text)
  end

  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def choose_organisation_link(token)
    url = publishers_login_key_url(token, **utm_params)
    notify_link(url)
  end

  def consume_jobseekers_login_key_link(token)
    url = consume_jobseekers_login_key_url(token)
    notify_link(url)
  end

  def expired_vacancy_feedback_link(vacancy)
    url = new_organisation_job_expired_feedback_url(vacancy.signed_id)
    notify_link(url, I18n.t("publishers.expired_vacancy_feedback_prompt_mailer.feedback_link_text"))
  end

  def expired_vacancy_unsubscribe_link(publisher)
    url = confirm_unsubscribe_publishers_account_url(publisher_id: publisher.signed_id)
    notify_link(url, "Unsubscribe from these emails")
  end

  def home_page_link(text = t("app.title"))
    url = root_url(**utm_params)
    notify_link(url, text)
  end

  def writing_job_application_advice_link(text)
    url = jobseeker_guides_write_a_great_teaching_job_application_in_five_steps_url
    notify_link(url, text)
  end

  def teaching_job_interview_link(text)
    url = jobseeker_guides_how_to_approach_a_teaching_job_interview_url
    notify_link(url, text)
  end

  def teaching_job_interview_lesson_link(text)
    url = jobseeker_guides_prepare_for_a_teaching_job_interview_lesson_url
    notify_link(url, text)
  end

  def invitation_to_apply_vacancy_link(vacancy)
    url = job_url(vacancy)
    url_with_utm_params = job_url(vacancy, **utm_params)

    safe_join([tag.p("#{vacancy.job_title}:"), notify_link(url_with_utm_params, url)])
  end

  def job_alert_relevance_feedback_link(relevant, subscription, vacancies)
    params = { job_alert_relevance_feedback: { relevant_to_user: relevant,
                                               job_alert_vacancy_ids: vacancies.pluck(:id),
                                               search_criteria: subscription.search_criteria } }.merge(utm_params)

    url = subscription_submit_feedback_url(subscription.token, **params)

    notify_link(url, I18n.t("jobseekers.alert_mailer.alert.relevance_feedback.feedback_link.#{relevant}"))
  end

  def jobseeker_job_applications_link
    url = jobseekers_job_applications_url(**utm_params)
    notify_link(url, t(".next_steps.link_text"))
  end

  def jobseeker_job_application_link(job_application)
    url = jobseekers_job_application_url(job_application, **utm_params)
    notify_link(url, t(".job_application.link_text"))
  end

  def jobseeker_profile_link
    url = jobseekers_profile_url(**utm_params)
    notify_link(url, t(".create_a_profile.link_text"))
  end

  def privacy_policy_link
    url = "https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/privacy-information-education-providers-workforce-including-teachers"
    notify_link(url, t(".privacy_policy_link"))
  end

  def publisher_job_applications_link(vacancy)
    url = organisation_job_job_applications_url(vacancy.id, **utm_params)
    notify_link(url, t(".view_applications", count: vacancy.job_applications.submitted_yesterday.count, job_title: vacancy.job_title))
  end

  def show_link(vacancy)
    url = job_url(vacancy, **utm_params)
    if vacancy.organisations.many?
      notify_link(url, t("jobseekers.alert_mailer.alert.show_job_link", job_title: vacancy.job_title))
    else
      notify_link(url, t("jobseekers.alert_mailer.alert.show_job_link_with_organisation", job_title: vacancy.job_title, organisation_name: vacancy.organisations.first.name))
    end
  end

  def sign_in_link
    url = new_jobseeker_session_url(**utm_params)
    notify_link(url, t(".link"))
  end

  def sign_up_link
    url = new_jobseeker_session_url(**utm_params)
    notify_link(url, t(".create_account.link"))
  end

  def support_user_fallback_sign_in_link(signed_id)
    url = support_users_fallback_session_url(signed_id)
    notify_link(url)
  end

  def unsubscribe_link(subscription)
    url = unsubscribe_subscription_url(subscription.token, **utm_params)
    notify_link(url, t(".unsubscribe_link_text"))
  end

  def vacancy_location_with_organisation_link(vacancy)
    organisation = vacancy.organisation
    url = organisation_landing_page_url(organisation, **utm_params)

    if vacancy.organisations.many?
      "#{t('organisations.job_location_summary.at_multiple_locations')}, #{notify_link(url, organisation.name)}".html_safe
    else
      address_join([notify_link(url, organisation.name), organisation.town, organisation.county, organisation.postcode]).html_safe
    end
  end

  def vacancy_organisation_and_location(vacancy)
    organisation = vacancy.organisation
    if vacancy.organisations.many?
      "#{t('organisations.job_location_summary.at_multiple_locations')}, #{organisation.name}".html_safe
    else
      address_join([organisation.town, organisation.county, organisation.postcode])
    end
  end

  def edit_job_alert_link(subscription)
    url = edit_subscription_url(subscription.token)
    notify_link(url, t(".edit_link_text"))
  end

  def view_applications_for_link(vacancy)
    url = organisation_job_job_applications_url(vacancy.id, **utm_params)
    notify_link(url, t(".view_applications_for", job_title: vacancy.job_title))
  end

  private

  def utm_params
    { utm_source: uid, utm_medium: "email", utm_campaign: utm_campaign }
  end
end
