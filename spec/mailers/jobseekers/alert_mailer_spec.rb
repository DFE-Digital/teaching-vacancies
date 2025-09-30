require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Jobseekers::AlertMailer do
  include DatesHelper
  include NotifyViewsHelper
  include OrganisationsHelper
  include ERB::Util

  let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
  let(:body) { mail.body.raw_source }
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:frequency) { :daily }
  let(:search_criteria) { { keyword: "English" } }
  let(:subscription) do
    subscription = Subscription.create(email: email.upcase, frequency: frequency, search_criteria: search_criteria)
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
  let(:vacancies) { create_list(:vacancy, 1, organisations: [school]).map { |vacancy| VacancyPresenter.new(vacancy) } }
  let(:utm_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "#{frequency}_alert" } }
  let(:relevant_job_alert_feedback_url) do
    subscription_submit_feedback_url(
      subscription.token,
      params: { job_alert_relevance_feedback: { relevant_to_user: true,
                                                job_alert_vacancy_ids: vacancies.pluck(:id),
                                                search_criteria: subscription.search_criteria } },
    )
  end
  let(:irrelevant_job_alert_feedback_url) do
    subscription_submit_feedback_url(
      subscription.token,
      params: { job_alert_relevance_feedback: { relevant_to_user: false,
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
      subscription_identifier: subscription.id,
      subscription_frequency: frequency,
      uid: "a_unique_identifier",
    }
  end

  before do
    # Stub the uid so that we can test links more easily
    allow_any_instance_of(described_class).to receive(:uid).and_return("a_unique_identifier")
    subscription.create_alert_run
  end

  describe "exception handling" do
    # exception message found here
    # https://docs.notifications.service.gov.uk/ruby.html#send-a-file-by-email-response
    let(:http_response) { double(code: 400, body: message) } # rubocop:disable RSpec/VerifiedDoubles
    let(:error) { Notifications::Client::BadRequestError.new(http_response) }

    before do
      allow_any_instance_of(described_class).to receive(:view_mail).and_raise(error)
    end

    context "when Notifications::Client::BadRequestError is about invalid email" do
      let(:message) { "ValidationError: email_address Not a valid email address" }

      it "destroys the subscription" do
        expect { mail.deliver_now }.not_to raise_error
        expect(Subscription.find_by(id: subscription.id)).to be_nil
      end
    end

    context "when Notifications::Client::BadRequestError is not about invalid email" do
      let(:message) { "BadRequestError: Can't send to this recipient using a team-only API key" }

      it "does raise error" do
        expect { mail.deliver_now }.to raise_error(Notifications::Client::BadRequestError)
        expect(Subscription.find_by(id: subscription.id)).to eq(subscription)
      end
    end
  end

  context "when frequency is daily" do
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:frequency) { "daily" }

    it "sends a job alert email" do
      expect_any_instance_of(described_class).to receive(:send_email).and_call_original
      expect(mail.subject).to eq(I18n.t("jobseekers.alert_mailer.alert.subject",
                                        count: vacancies.count,
                                        count_minus_one: vacancies.count - 1,
                                        job_title: vacancies.first.job_title,
                                        school_name: vacancies.first.organisation_name))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.alert_mailer.alert.summary.daily", count: 1))
                  .and include(vacancies.first.job_title)
                  .and include(job_url(vacancies.first, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.working_pattern", working_pattern: vacancies.first.readable_working_patterns_with_details))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.title"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.alert_mailer.alert.relevance_feedback.heading"))
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.relevance_feedback.relevant_link_text')}\]\(.+true)/)
                  .and include(relevant_job_alert_feedback_url)
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.relevance_feedback.irrelevant_link_text')}\]\(.+false)/)
                  .and include(irrelevant_job_alert_feedback_url)
                  .and include(I18n.t("jobseekers.alert_mailer.alert.relevance_feedback.reason"))
                  .and include(unsubscribe_subscription_url(subscription.token, **utm_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_alert` email event with the anonymised jobseeker id", :dfe_analytics do
        mail.deliver_now
        expect(:jobseeker_subscription_alert).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_alert` email event without the anonymised jobseeker id", :dfe_analytics do
        mail.deliver_now
        expect(:jobseeker_subscription_alert).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
      end
    end

    context "when the subscription has no email address" do
      before do
        subscription.update(email: "")
      end

      it "does not send an email" do
        expect_any_instance_of(described_class).not_to receive(:send_email)
        mail.deliver_now
      end
    end
  end

  context "when frequency is weekly" do
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:frequency) { "weekly" }

    it "sends a job alert email" do
      expect_any_instance_of(described_class).to receive(:send_email).and_call_original
      expect(mail.subject).to eq(I18n.t("jobseekers.alert_mailer.alert.subject",
                                        count: vacancies.count,
                                        count_minus_one: vacancies.count - 1,
                                        job_title: vacancies.first.job_title,
                                        school_name: vacancies.first.organisation_name))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.alert_mailer.alert.summary.weekly", count: 1))
                  .and include(vacancies.first.job_title)
                  .and include(job_url(vacancies.first, **utm_params))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.working_pattern",
                                      working_pattern: vacancies.first.readable_working_patterns_with_details))
                  .and include(I18n.t("jobseekers.alert_mailer.alert.title"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.alert_mailer.alert.relevance_feedback.heading"))
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.relevance_feedback.relevant_link_text')}\]\(.+true)/)
                  .and include(relevant_job_alert_feedback_url)
                  .and match(/(\[#{I18n.t('jobseekers.alert_mailer.alert.relevance_feedback.irrelevant_link_text')}\]\(.+false)/)
                  .and include(irrelevant_job_alert_feedback_url)
                  .and include(I18n.t("jobseekers.alert_mailer.alert.relevance_feedback.reason"))
                  .and include(unsubscribe_subscription_url(subscription.token, **utm_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_alert` email event with the anonymised jobseeker id", :dfe_analytics do
        mail.deliver_now
        expect(:jobseeker_subscription_alert).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_alert` email event without the anonymised jobseeker id", :dfe_analytics do
        mail.deliver_now
        expect(:jobseeker_subscription_alert).to have_been_enqueued_as_analytics_event(with_data: %i[uid notify_template]) # rubocop:disable RSpec/ExpectActual
      end
    end

    context "when the subscriber has a jobseeker account that has a profile" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let!(:profile) { create(:jobseeker_profile, :completed, jobseeker_id: jobseeker.id) }

      it "does not display the section encouraging them to create a profile" do
        expect(body).to_not include(jobseekers_profile_url(**utm_params))
        expect(body).to_not include(I18n.t("jobseekers.alert_mailer.alert.create_a_profile.heading"))
        expect(body).to_not include(I18n.t("jobseekers.alert_mailer.alert.create_a_profile.link_text"))
      end
    end

    context "when the subscription has no email address" do
      before do
        subscription.update(email: "")
      end

      it "does not send an email" do
        expect_any_instance_of(described_class).not_to receive(:send_email)
        mail.deliver_now
      end
    end
  end
end
