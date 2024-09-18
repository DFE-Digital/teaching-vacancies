require "rails_helper"

RSpec.describe Jobseeker do
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:job_applications) }

  describe "update_subscription_emails" do
    let(:jobseeker) { create(:jobseeker) }
    let!(:subscription) { create(:subscription, email: jobseeker.email) }
    let(:new_email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

    it "updates the email address of every subscription associated with their previous email address" do
      expect {
        jobseeker.update!(email: new_email_address)
        jobseeker.confirm
      }.to change { subscription.reload.email }.to(new_email_address)
    end
  end

  describe "#needs_email_confirmation?" do
    subject(:jobseeker) { build_stubbed(:jobseeker) }

    context "when the user is confirmed" do
      before { jobseeker.confirmed_at = Time.current }

      context "when the user does not have a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = nil }
        it { is_expected.not_to be_needs_email_confirmation }
      end

      context "when the user has a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = "foobar@example.com" }
        it { is_expected.to be_needs_email_confirmation }
      end
    end

    context "when the user is not confirmed" do
      before { jobseeker.confirmed_at = nil }

      context "when the user does not have a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = nil }
        it { is_expected.to be_needs_email_confirmation }
      end

      context "when the user has a new unconfirmed email address" do
        before { jobseeker.unconfirmed_email = "foobar@example.com" }
        it { is_expected.to be_needs_email_confirmation }
      end
    end
  end

  describe ".create_from_govuk_one_login" do
    let(:email) { "user@example.com" }
    let(:govuk_one_login_id) { "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4" }

    subject(:create_from_govuk_one_login) do
      described_class.create_from_govuk_one_login(email: email, govuk_one_login_id: govuk_one_login_id)
    end

    RSpec.shared_examples "invalid input" do
      it "returns nil" do
        expect(create_from_govuk_one_login).to be_nil
      end

      it "does not create a new jobseeker" do
        expect { create_from_govuk_one_login }.not_to change(described_class, :count)
      end
    end

    context "when no user email is provided" do
      let(:email) { "" }

      include_examples "invalid input"
    end

    context "when no govuk_one_login_id is provided" do
      let(:govuk_one_login_id) { "" }

      include_examples "invalid input"
    end

    context "when an email and govuk_on_login_id is provided" do
      it "creates a new jobseeker" do
        expect { create_from_govuk_one_login }.to change(described_class, :count).by(1)
      end

      it "returns the new jobseeker with the one login id and email" do
        jobseeker = create_from_govuk_one_login
        expect(jobseeker).to be_a(described_class)
        expect(jobseeker).to have_attributes(email:, govuk_one_login_id:)
      end
    end
  end
end
