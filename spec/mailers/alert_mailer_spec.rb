require "rails_helper"

RSpec.describe AlertMailer, type: :mailer do
  include DatesHelper
  include OrganisationHelper
  include ERB::Util

  let(:body) { mail.body.raw_source }
  let(:email) { "an@email.com" }
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
  let(:vacancies) { VacanciesPresenter.new(create_list(:vacancy, 1, :published)).decorated_collection }
  let(:campaign_params) { { utm_source: subscription.alert_run_today.id, utm_medium: "email", utm_campaign: "#{frequency}_alert" } }
  let(:relevant_job_alert_feedback_url) do
    new_subscription_job_alert_feedback_url(
      subscription.token,
      params: { job_alert_feedback: { relevant_to_user: true,
                                      vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end
  let(:irrelevant_job_alert_feedback_url) do
    new_subscription_job_alert_feedback_url(
      subscription.token,
      params: { job_alert_feedback: { relevant_to_user: false,
                                      vacancy_ids: vacancies.pluck(:id),
                                      search_criteria: subscription.search_criteria } },
    )
  end

  before do
    vacancies.each { |vacancy| vacancy.organisation_vacancies.create(organisation: school) }
    subscription.create_alert_run
  end

  context "when frequency is daily" do
    it "sends a job alert email" do
      expect(mail.subject).to eq(I18n.t("alert_mailer.alert.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("alert_mailer.alert.summary.daily", count: 1))
      expect(body).to include(vacancies.first.job_title)
      expect(body).to include(vacancies.first.job_title)
      expect(body).to include(job_url(vacancies.first, **campaign_params))
      expect(body).to include(location(vacancies.first.organisation))
      expect(body).to include(I18n.t("alert_mailer.alert.salary", salary: vacancies.first.salary))
      expect(body).to include(I18n.t("alert_mailer.alert.working_pattern", working_pattern: vacancies.first.working_patterns))
      expect(body).to include(I18n.t("alert_mailer.alert.closing_date", closing_date: format_date(vacancies.first.expires_on)))
      expect(body).to include(I18n.t("alert_mailer.alert.title"))
      expect(body).to include(I18n.t("subscriptions.intro"))
      expect(body).to include("Keyword: English")
      expect(body).to include(I18n.t("alert_mailer.alert.alert_frequency", frequency: subscription.frequency))
      expect(body).to include(I18n.t("alert_mailer.alert.edit_link_text"))
      expect(body).to include(edit_subscription_url(subscription.token, **campaign_params))
      expect(body).to include(I18n.t("alert_mailer.alert.feedback.heading"))
      expect(body).to match(/(\[#{I18n.t('alert_mailer.alert.feedback.relevant_link_text')}\]\(.+true)/)
      expect(body).to include(relevant_job_alert_feedback_url)
      expect(body).to match(/(\[#{I18n.t('alert_mailer.alert.feedback.irrelevant_link_text')}\]\(.+false)/)
      expect(body).to include(irrelevant_job_alert_feedback_url)
      expect(body).to include(I18n.t("alert_mailer.alert.feedback.reason"))
      expect(body).to include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end
  end

  context "when frequency is weekly" do
    let(:frequency) { :weekly }

    it "sends a job alert email" do
      expect(mail.subject).to eq(I18n.t("alert_mailer.alert.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("alert_mailer.alert.summary.weekly", count: 1))
      expect(body).to include(vacancies.first.job_title)
      expect(body).to include(vacancies.first.job_title)
      expect(body).to include(job_url(vacancies.first, **campaign_params))
      expect(body).to include(location(vacancies.first.organisation))
      expect(body).to include(I18n.t("alert_mailer.alert.salary", salary: vacancies.first.salary))
      expect(body).to include(I18n.t("alert_mailer.alert.working_pattern", working_pattern: vacancies.first.working_patterns))
      expect(body).to include(I18n.t("alert_mailer.alert.closing_date", closing_date: format_date(vacancies.first.expires_on)))
      expect(body).to include(I18n.t("alert_mailer.alert.title"))
      expect(body).to include(I18n.t("subscriptions.intro"))
      expect(body).to include("Keyword: English")
      expect(body).to include(I18n.t("alert_mailer.alert.alert_frequency", frequency: subscription.frequency))
      expect(body).to include(I18n.t("alert_mailer.alert.edit_link_text"))
      expect(body).to include(edit_subscription_url(subscription.token, **campaign_params))
      expect(body).to include(I18n.t("alert_mailer.alert.feedback.heading"))
      expect(body).to match(/(\[#{I18n.t('alert_mailer.alert.feedback.relevant_link_text')}\]\(.+true)/)
      expect(body).to include(relevant_job_alert_feedback_url)
      expect(body).to match(/(\[#{I18n.t('alert_mailer.alert.feedback.irrelevant_link_text')}\]\(.+false)/)
      expect(body).to include(irrelevant_job_alert_feedback_url)
      expect(body).to include(I18n.t("alert_mailer.alert.feedback.reason"))
      expect(body).to include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end
  end

  describe "create account section" do
    before do
      allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(jobseeker_accounts_enabled?)
    end

    context "when JobseekerAccountsFeature is enabled" do
      let(:jobseeker_accounts_enabled?) { true }

      context "when the subscription email matches a jobseeker account" do
        let!(:jobseeker) { create(:jobseeker, email: email) }

        it "does not display create account section" do
          expect(body).not_to include(I18n.t("alert_mailer.alert.create_account.heading"))
        end
      end

      context "when the subscription email does not match a jobseeker account" do
        it "displays create account section" do
          expect(body).to include(I18n.t("alert_mailer.alert.create_account.heading"))
        end
      end
    end

    context "when JobseekerAccountsFeature is disabled" do
      let(:jobseeker_accounts_enabled?) { false }

      context "when the subscription email matches a jobseeker account" do
        let!(:jobseeker) { create(:jobseeker, email: email) }

        it "does not display create account section" do
          expect(body).not_to include(I18n.t("alert_mailer.alert.create_account.heading"))
        end
      end

      context "when the subscription email does not match a jobseeker account" do
        it "does not display create account section" do
          expect(body).not_to include(I18n.t("alert_mailer.alert.create_account.heading"))
        end
      end
    end
  end
end
