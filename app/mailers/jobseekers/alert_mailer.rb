class Jobseekers::AlertMailer < Jobseekers::BaseMailer
  after_action :jobseeker

  self.delivery_job = AlertMailerJob
  helper DatesHelper
  helper VacanciesHelper

  helper_method :subscription, :jobseeker

  def alert(subscription_id, vacancy_ids)
    @subscription_id = subscription_id

    @template = subscription.daily? ? NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE : NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE
    @to = subscription.email

    @vacancies = VacanciesPresenter.new(Vacancy.where(id: vacancy_ids).order(:expires_at))
    view_mail(@template,
              to: @to,
              subject: I18n.t("jobseekers.alert_mailer.alert.subject.#{ab_tests[:"2022_01_alert_mailer_subject_lines_ab_test"]}",
                              count: @vacancies.count,
                              count_minus_one: @vacancies.count - 1,
                              job_title: @vacancies.first.job_title,
                              keywords: @subscription.search_criteria["keyword"].titleize,
                              school_name: @vacancies.first.parent_organisation_name))
  end

  def ab_tests
    @alert_mailer_subject_lines_ab_test ||= %w[present_subject_line subject_line_variant_1 subject_line_variant_2 subject_line_variant_3 subject_line_variant_4 subject_line_variant_5].sample

    { :"2022_01_alert_mailer_subject_lines_ab_test" => @alert_mailer_subject_lines_ab_test }
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
