require "rails_helper"

RSpec.describe Jobseekers::AlertMailer do
  include DatesHelper
  include NotifyViewsHelper
  include OrganisationsHelper
  include ERB::Util

  let(:body) { mail.body.raw_source }
  let(:email) { "an@example.net" }
  let(:frequency) { :daily }
  let(:search_criteria) { { keyword: "English" } }
  let(:subscription) do
    subscription = Subscription.create(email: email, frequency: frequency, search_criteria: search_criteria)
    # The hashing algorithm uses a random initialization vector to encrypt the token,
    # so is different every time, so we stub the token to be the same every time, so
    # it's clearer what we're testing when we test the unsubscribe link
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end
  let(:school) { create(:school) }
  let(:mail) { described_class.alert(subscription.id, vacancies.pluck(:id)) }
  # The array of vacancies is set to length 1 because the order varies, making it hard to test url parameters.
  let(:vacancies) { create_list(:vacancy, 1, :published, organisations: [school]).map { |vacancy| VacancyPresenter.new(vacancy) } }
  let(:utm_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "#{frequency}_alert" } }
  let(:relevant_job_alert_feedback_url) do
    new_subscription_job_alert_feedback_url(
      subscription.token,
      params: { job_alert_feedback: { relevant_to_user: true,
                                      job_alert_vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end
  let(:irrelevant_job_alert_feedback_url) do
    new_subscription_job_alert_feedback_url(
      subscription.token,
      params: { job_alert_feedback: { relevant_to_user: false,
                                      job_alert_vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: user_anonymised_jobseeker_id,
      user_anonymised_publisher_id: nil,
      subscription_identifier: anonymised_form_of(subscription.id),
      subscription_frequency: frequency,
      uid: "a_unique_identifier",
    }
  end

  before do
    # Ensure present variant of ab test is used
    allow_any_instance_of(described_class).to receive(:ab_tests).and_return({ :"2022_01_alert_mailer_subject_lines_ab_test" => "present_subject_line" })
    # Stub the uid so that we can test links more easily
    allow_any_instance_of(ApplicationMailer).to receive(:uid).and_return("a_unique_identifier")
    subscription.create_alert_run
  end

  context "when frequency is daily" do
    let(:notify_template) { NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE }
    let(:frequency) { "daily" }

    it "sends a job alert email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.alert_mailer.alert.subject",
                                        count: vacancies.count,
                                        count_minus_one: vacancies.count - 1,
                                        job_title: vacancies.first.job_title,
                                        school_name: vacancies.first.organisation_name))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.alert_mailer.alert.summary.daily", count: 1))
                  .and include(vacancies.first.job_title)
                  .and include(vacancies.first.job_title)
                  .and include(job_url(vacancies.first, **utm_params))
                  .and include(organisation_landing_page_url(vacancies.first.organisation.slug, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.salary", salary: vacancies.first.salary))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.working_pattern", working_pattern: vacancies.first.readable_working_patterns))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.closing_date", closing_date: format_time_to_datetime_at(vacancies.first.expires_at)))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.title"))
                  .and include(I18n.t("subscriptions.intro"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.alert_mailer.alert.alert_frequency", frequency: subscription.frequency))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.edit_link_text"))
                  .and include(edit_subscription_url(subscription.token, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.feedback.heading"))
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.feedback.relevant_link_text')}\]\(.+true)/)
                  .and include(relevant_job_alert_feedback_url)
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.feedback.irrelevant_link_text')}\]\(.+false)/)
                  .and include(irrelevant_job_alert_feedback_url)
                  .and include(I18n.t("jobseekers.alert_mailer.alert.feedback.reason"))
                  .and include(unsubscribe_subscription_url(subscription.token, **utm_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_alert` email event with the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_alert).with_data(expected_data)
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_alert` email event without the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_alert).with_data(expected_data)
      end
    end
  end

  context "when frequency is weekly" do
    let(:notify_template) { NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE }
    let(:frequency) { "weekly" }

    it "sends a job alert email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.alert_mailer.alert.subject",
                                        count: vacancies.count,
                                        count_minus_one: vacancies.count - 1,
                                        job_title: vacancies.first.job_title,
                                        school_name: vacancies.first.organisation_name))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.alert_mailer.alert.summary.weekly", count: 1))
                  .and include(vacancies.first.job_title)
                  .and include(vacancies.first.job_title)
                  .and include(job_url(vacancies.first, **utm_params))
                  .and include(organisation_landing_page_url(vacancies.first.organisation.slug, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.salary", salary: vacancies.first.salary))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.working_pattern",
                                      working_pattern: vacancies.first.readable_working_patterns))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.closing_date",
                                      closing_date: format_time_to_datetime_at(vacancies.first.expires_at)))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.title"))
                  .and include(I18n.t("subscriptions.intro"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.alert_mailer.alert.alert_frequency", frequency: subscription.frequency))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.edit_link_text"))
                  .and include(edit_subscription_url(subscription.token, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.feedback.heading"))
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.feedback.relevant_link_text')}\]\(.+true)/)
                  .and include(relevant_job_alert_feedback_url)
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.feedback.irrelevant_link_text')}\]\(.+false)/)
                  .and include(irrelevant_job_alert_feedback_url)
                  .and include(I18n.t("jobseekers.alert_mailer.alert.feedback.reason"))
                  .and include(unsubscribe_subscription_url(subscription.token, **utm_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_alert` email event with the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_alert).with_data(expected_data)
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_alert` email event without the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_alert).with_data(expected_data)
      end
    end
  end
end
