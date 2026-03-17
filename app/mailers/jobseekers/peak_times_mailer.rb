class Jobseekers::PeakTimesMailer < Jobseekers::BaseMailer
  helper_method :jobseeker, :first_name, :campaign_url, :campaign_key

  # Notify template ID for March peak times email
  MARCH_PEAK_TIMES_TEMPLATE_ID = "ebad6edf-99a5-4072-951f-f01c1178cdae".freeze

  def reminder(jobseeker_id)
    @jobseeker = Jobseeker.includes(jobseeker_profile: :personal_details).find_by(id: jobseeker_id)

    if current_month == "march"
      send_march_template_email
    else
      send_standard_email
    end
  end

  private

  def send_march_template_email
    template_mail(
      MARCH_PEAK_TIMES_TEMPLATE_ID,
      to: @jobseeker.email,
      personalisation: {
        campaign_url: campaign_url,
        unsubscribe_link: edit_jobseekers_account_email_preferences_url,
      },
    )
  end

  def send_standard_email
    first_name = @jobseeker.jobseeker_profile&.personal_details&.first_name
    subject = if first_name.present?
                I18n.t("jobseekers.peak_times_mailer.#{campaign_key}.subject", first_name: first_name)
              else
                I18n.t("jobseekers.peak_times_mailer.#{campaign_key}.nameless_subject")
              end
    send_email(to: @jobseeker.email, subject:)
  end

  def campaign_url
    case current_month
    when "may"
      "https://teaching-vacancies.service.gov.uk/?utm_source=Notify&utm_medium=email&utm_campaign=#{current_month}_peak_notify&utm_id=#{current_month}_peak_notify"
    when "november"
      "https://teaching-vacancies.service.gov.uk/jobs?utm_source=notify&utm_medium=email&utm_campaign=notify_november_2025&utm_content=tuesday_2025"
    when "march"
      "https://teaching-vacancies.service.gov.uk/jobs?utm_source=notify&utm_medium=email&utm_campaign=peak_email&utm_content=march_2026"
    else
      "https://teaching-vacancies.service.gov.uk/"
    end
  end

  def campaign_key
    case current_month
    when "november"
      "november_reminder"
    else
      "may_reminder"
    end
  end

  def current_month
    @current_month ||= Date.current.strftime("%B").downcase
  end

  def email_event_prefix
    "jobseeker_peak_times"
  end
end
