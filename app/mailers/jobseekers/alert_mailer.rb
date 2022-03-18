class Jobseekers::AlertMailer < Jobseekers::BaseMailer
  ALERT_MAILER_TEST_VARIANTS = %w[present_subject_line subject_line_variant_1 subject_line_variant_2 subject_line_variant_3 subject_line_variant_4 subject_line_variant_5].freeze

  after_action :jobseeker

  self.delivery_job = AlertMailerJob
  helper DatesHelper
  helper VacanciesHelper

  helper_method :subscription, :jobseeker

  def alert(subscription_id, vacancy_ids)
    @subscription_id = subscription_id

    @template = subscription.daily? ? NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE : NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE
    @to = subscription.email

    @vacancies = Vacancy.where(id: vacancy_ids)
                        .order(:expires_at)
                        .map { |vacancy| VacancyPresenter.new(vacancy) }

    view_mail(@template,
              to: @to,
              subject: I18n.t("jobseekers.alert_mailer.alert.subject.#{ab_tests[:"2022_01_alert_mailer_subject_lines_ab_test"]}",
                              count: @vacancies.count,
                              count_minus_one: @vacancies.count - 1,
                              job_title: @vacancies.first.job_title,
                              keywords: @subscription.search_criteria["keyword"].nil? ? I18n.t("jobseekers.alert_mailer.alert.subject.no_keywords") : @subscription.search_criteria["keyword"]&.titleize,
                              school_name: @vacancies.first.organisation_name))
  end

  def ab_tests
    { :"2022_01_alert_mailer_subject_lines_ab_test" => alert_mailer_test_selected_variant }
  end

  def alert_mailer_test_selected_variant
    @alert_mailer_test_selected_variant ||= ALERT_MAILER_TEST_VARIANTS.sample
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
