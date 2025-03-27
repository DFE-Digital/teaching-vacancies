class Jobseekers::PeakTimesMailer < Jobseekers::BaseMailer
  helper_method :jobseeker, :first_name, :campaign_url

  def reminder(jobseeker_id)
    @jobseeker_id = jobseeker_id
    @template = template
    @to = jobseeker.email

    view_mail(@template,
              to: @to,
              subject: I18n.t("jobseekers.peak_times_mailer.reminder.subject", first_name: first_name))
  end

  private

  attr_reader :jobseeker_id

  def jobseeker
    @jobseeker ||= Jobseeker.includes(jobseeker_profile: :personal_details).find_by(id: jobseeker_id)
  end

  def first_name
    @first_name ||= jobseeker.jobseeker_profile.personal_details.first_name
  end

  def campaign_url
    "https://teaching-vacancies.service.gov.uk/?utm_source=Notify&utm_medium=email&utm_campaign=#{month}_peak_notify&utm_id=#{month}_peak_notify"
  end

  def month
    @month ||= Date.current.strftime("%B").downcase
  end

  def email_event_prefix
    "jobseeker_peak_times"
  end
end
