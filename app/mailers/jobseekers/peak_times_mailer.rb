class Jobseekers::PeakTimesMailer < Jobseekers::BaseMailer
  helper_method :jobseeker, :first_name, :campaign_url, :campaign_key

  PEAK_TIMES_CAMPAIGNS = {
    "march" => {
      template_id: "ebad6edf-99a5-4072-951f-f01c1178cdae",
      url: "https://teaching-vacancies.service.gov.uk/jobs?utm_source=notify&utm_medium=email&utm_campaign=peak_email&utm_content=march_2026",
    },
    "may" => {
      template_id: "084ff736-1802-4409-87b3-2826ee04eac3",
      url: "https://teaching-vacancies.service.gov.uk/jobs?utm_source=notify&utm_medium=email&utm_campaign=peak_email&utm_content=may_2026",
    },
    "november" => {
      url: "https://teaching-vacancies.service.gov.uk/jobs?utm_source=notify&utm_medium=email&utm_campaign=notify_november_2025&utm_content=tuesday_2025",
    },
  }.freeze

  def reminder(jobseeker_id)
    @jobseeker = Jobseeker.includes(jobseeker_profile: :personal_details).find_by(id: jobseeker_id)

    if %w[march may].include?(current_month)
      send_notify_template_email
    else
      send_standard_email
    end
  end

  private

  def send_notify_template_email
    template_mail(
      PEAK_TIMES_CAMPAIGNS[current_month][:template_id],
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
    PEAK_TIMES_CAMPAIGNS.fetch(current_month, {}).fetch(:url, "https://teaching-vacancies.service.gov.uk/")
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
