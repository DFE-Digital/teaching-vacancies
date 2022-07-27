class Jobseekers::AlertMailer < Jobseekers::BaseMailer
  after_action :jobseeker

  self.delivery_job = AlertMailerJob
  helper DatesHelper
  helper VacanciesHelper

  helper_method :subscription, :jobseeker

  def alert(subscription_id, vacancy_ids)
    @subscription_id = subscription_id

    @template = template
    @to = subscription.email

    @vacancies = Vacancy.where(id: vacancy_ids)
                        .order(:expires_at)
                        .map { |vacancy| VacancyPresenter.new(vacancy) }

    view_mail(@template,
              to: @to,
              subject: I18n.t("jobseekers.alert_mailer.alert.subject",
                              count: @vacancies.count,
                              count_minus_one: @vacancies.count - 1,
                              job_title: @vacancies.first.job_title,
                              school_name: @vacancies.first.organisation_name))
  end

  private

  attr_reader :subscription_id

  def email_event_data
    { subscription_identifier: StringAnonymiser.new(subscription.id), subscription_frequency: subscription.frequency }
  end

  def email_event_prefix
    "jobseeker_subscription"
  end

  def jobseeker
    @jobseeker ||= Jobseeker.find_by(email: subscription.email)
  end

  def subscription
    @subscription ||= SubscriptionPresenter.new(Subscription.find(subscription_id))
  end

  def utm_campaign
    "#{subscription.frequency}_alert"
  end
end
