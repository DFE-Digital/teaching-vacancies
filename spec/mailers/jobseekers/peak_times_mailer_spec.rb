require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Jobseekers::PeakTimesMailer do
  describe ".reminder" do
    subject(:mail) { described_class.reminder(jobseeker.id) }

    shared_examples "common email behaviors" do
      it "uses jobseekers' email" do
        expect(mail.to).to contain_exactly(jobseeker.email)
      end

      it "has an unsubcribe link" do
        unsubscribe_link = Rails.application
                             .routes
                             .url_helpers
                             .edit_jobseekers_account_email_preferences_url
        expect(mail.body).to include(unsubscribe_link)
      end
    end

    context "when it's May" do
      before { travel_to Time.zone.local(2025, 5, 14, 3, 0, 0) }

      let(:expected_url) { "https://teaching-vacancies.service.gov.uk/?utm_source=Notify&utm_medium=email&utm_campaign=may_peak_notify&utm_id=may_peak_notify" }

      context "when jobseeker has personal details" do
        let(:jobseeker) { create(:jobseeker, :with_personal_details) }
        let(:first_name) { jobseeker.jobseeker_profile.personal_details.first_name }

        it_behaves_like "common email behaviors"

        it "has May subject with jobseeker firstname" do
          expected_subject = I18n.t("jobseekers.peak_times_mailer.may_reminder.subject", first_name: first_name)
          expect(mail.subject).to eq(expected_subject)
        end

        it "includes May campaign URL" do
          expect(mail.body).to include(expected_url)
        end
      end

      context "when jobseeker has no personal details" do
        let(:jobseeker) { create(:jobseeker) }

        it_behaves_like "common email behaviors"

        it "has May generic subject without firstname" do
          expected_subject = I18n.t("jobseekers.peak_times_mailer.may_reminder.nameless_subject")
          expect(mail.subject).to eq(expected_subject)
        end

        it "includes May campaign URL" do
          expect(mail.body).to include(expected_url)
        end
      end
    end

    context "when it's November" do
      before { travel_to Time.zone.local(2025, 11, 4, 12, 0, 0) }

      let(:expected_url) { "/jobs?utm_source=notify&utm_medium=email&utm_campaign=notify_november_2025&utm_content=tuesday_2025" }

      context "when jobseeker has personal details" do
        let(:jobseeker) { create(:jobseeker, :with_personal_details) }
        let(:first_name) { jobseeker.jobseeker_profile.personal_details.first_name }

        it_behaves_like "common email behaviors"

        it "has November subject with jobseeker firstname" do
          expected_subject = I18n.t("jobseekers.peak_times_mailer.november_reminder.subject", first_name: first_name)
          expect(mail.subject).to eq(expected_subject)
        end

        it "includes November campaign URL" do
          expect(mail.body).to include(expected_url)
        end
      end

      context "when jobseeker has no personal details" do
        let(:jobseeker) { create(:jobseeker) }

        it_behaves_like "common email behaviors"

        it "has November generic subject without firstname" do
          expected_subject = I18n.t("jobseekers.peak_times_mailer.november_reminder.nameless_subject")
          expect(mail.subject).to eq(expected_subject)
        end

        it "includes November campaign URL" do
          expect(mail.body).to include(expected_url)
        end
      end
    end

    context "when it's a different month (fallback behavior)" do
      before { travel_to Time.zone.local(2025, 3, 15, 9, 0, 0) }

      let(:jobseeker) { create(:jobseeker, :with_personal_details) }
      let(:first_name) { jobseeker.jobseeker_profile.personal_details.first_name }

      it "falls back to May campaign content" do
        expected_subject = I18n.t("jobseekers.peak_times_mailer.may_reminder.subject", first_name: first_name)
        expect(mail.subject).to eq(expected_subject)
      end

      it "uses generic fallback URL" do
        expect(mail.body).to include("https://teaching-vacancies.service.gov.uk/")
      end
    end
  end
end
