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

      %w[march may].each do |month|
        context "when it's month #{month}" do
          subject(:body) { mail.body }

          before { travel_to Time.zone.local(2025, month_num, 13, 9, 0, 0) }

          let(:month_num) { month == "march" ? 3 : 5 }
          let(:url) { "https://teaching-vacancies.service.gov.uk/?utm_source=Notify&utm_medium=email&utm_campaign=#{month}_peak_notify&utm_id=#{month}_peak_notify" }

          it { is_expected.to include(url) }
        end
      end
    end

    context "when jobseeker has personal details" do
      let(:jobseeker) { create(:jobseeker, :with_personal_details) }
      let(:first_name) { jobseeker.jobseeker_profile.personal_details.first_name }

      it_behaves_like "common email behaviors"

      it "has subject with jobseeker firstname" do
        expected_subject = I18n.t("jobseekers.peak_times_mailer.reminder.subject", first_name: first_name)
        expect(mail.subject).to eq(expected_subject)
      end

      it "includes personalized greeting in the body" do
        expect(mail.body).to include(first_name)
      end
    end

    context "when jobseeker has no personal details" do
      let(:jobseeker) { create(:jobseeker) }

      it_behaves_like "common email behaviors"

      it "has generic subject without firstname" do
        expected_subject = I18n.t("jobseekers.peak_times_mailer.reminder.nameless_subject")
        expect(mail.subject).to eq(expected_subject)
      end

      it "includes generic greeting in the body" do
        nameless_greeting = I18n.t("jobseekers.peak_times_mailer.reminder.nameless_hello")
        expect(mail.body).to include(nameless_greeting)
      end
    end
  end
end
