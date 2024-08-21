require "rails_helper"

RSpec.describe Jobseeker do
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:job_applications) }

  describe "update_subscription_emails" do
    let(:jobseeker) { create(:jobseeker) }
    let!(:subscription) { create(:subscription, email: jobseeker.email) }
    let(:new_email_address) { "new_email@example.com" }

    it "updates the email address of every subscription associated with their previous email address" do
      expect {
        jobseeker.update(email: new_email_address)
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

  describe ".find_or_create_from_govuk_one_login" do
    let(:email) { "user@example.com" }
    let(:govuk_one_login_id) { "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4" }

    subject(:find_or_create) do
      described_class.find_or_create_from_govuk_one_login(email: email, govuk_one_login_id: govuk_one_login_id)
    end

    RSpec.shared_examples "invalid input" do
      it "returns nil" do
        expect(find_or_create).to be_nil
      end

      it "does not create a new jobseeker" do
        expect { find_or_create }.not_to change(described_class, :count)
      end
    end

    RSpec.shared_examples "existing jobseeker" do
      let!(:jobseeker) { create(:jobseeker, email: existing_jobseeker_email, govuk_one_login_id:) }

      it "returns the existing jobseeker" do
        expect(find_or_create).to eq jobseeker
      end

      it "does not create a new jobseeker" do
        expect { find_or_create }.not_to change(described_class, :count)
      end

      context "when the existing jobseeker has no govuk one login id" do
        let!(:jobseeker) { create(:jobseeker, email:, govuk_one_login_id: nil) }

        it "updates the existing jobseeker with the govuk one login id" do
          expect { find_or_create }.to change { jobseeker.reload.govuk_one_login_id }.from(nil).to(govuk_one_login_id)
        end
      end

      context "when the existing jobseeker had a different govuk one login id" do
        let!(:jobseeker) { create(:jobseeker, email:, govuk_one_login_id: "old_govuk_one_login_id") }

        it "updates the existing jobseeker govuk one login id" do
          expect { find_or_create }.to change { jobseeker.reload.govuk_one_login_id }
                                   .from("old_govuk_one_login_id")
                                   .to(govuk_one_login_id)
        end
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

    context "when a jobseeker with the exact email address already exists" do
      include_examples "existing jobseeker" do
        let(:existing_jobseeker_email) { email }
      end
    end

    context "when a jobseeker with the same email address with different capitalisation exist" do
      include_examples "existing jobseeker" do
        let(:existing_jobseeker_email) { email.upcase }
      end
    end

    context "without an existing jobseeker with the same email address" do
      it "creates a new jobseeker" do
        expect { find_or_create }.to change(described_class, :count).by(1)
      end

      it "returns the new jobseeker with the one login id and email" do
        jobseeker = find_or_create
        expect(jobseeker).to be_a(described_class)
        expect(jobseeker).to have_attributes(email:, govuk_one_login_id:)
      end
    end
  end
end
