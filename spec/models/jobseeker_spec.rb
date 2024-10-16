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
    let(:email) { "notarealuser121342@gmail.com" }
    let(:govuk_one_login_id) { "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4" }

    subject(:create_from_govuk_one_login) do
      described_class.create_from_govuk_one_login(email: email, id: govuk_one_login_id)
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

  describe ".find_from_govuk_one_login" do
    let!(:jobseeker) { create(:jobseeker) }

    it "finds the jobseeker by their govuk_one_login_id" do
      expect(described_class.find_from_govuk_one_login(
               id: jobseeker.govuk_one_login_id,
               email: "random@contoso.com",
             )).to eq(jobseeker)
    end

    context "when the jobseeker does not have a govuk_one_login_id" do
      let!(:jobseeker) { create(:jobseeker, govuk_one_login_id: nil) }

      it "finds the jobseeker by their email" do
        expect(described_class.find_from_govuk_one_login(id: nil, email: jobseeker.email)).to eq(jobseeker)
      end
    end

    it "returns no user if neither the govuk_one_login_id or email match" do
      expect(described_class.find_from_govuk_one_login(id: "random", email: "random@contoso.com")).to be_nil
    end

    it "returns no user if neither the govuk_one_login_id or email are provided" do
      expect(described_class.find_from_govuk_one_login(id: nil, email: nil)).to be_nil
    end
  end

  describe "#saved_data?" do
    let!(:jobseeker) { create(:jobseeker) }

    it "returns false for a fresh jobseeker with no recorded applications, qualifications or employment history" do
      expect(jobseeker).not_to be_saved_data
    end

    it "returns true for a jobseeker with a job application" do
      create(:job_application, jobseeker: jobseeker)
      expect(jobseeker).to be_saved_data
    end

    it "returns true for a jobseeker with qualifications" do
      create(:jobseeker_profile, :with_qualifications, jobseeker: jobseeker)
      expect(jobseeker).to be_saved_data
    end

    it "returns true for a jobseeker with employment history" do
      create(:jobseeker_profile, :with_employment_history, jobseeker: jobseeker)
      expect(jobseeker).to be_saved_data
    end
  end

  describe "update_email_from_govuk_one_login!" do
    let!(:jobseeker) { create(:jobseeker) }

    it "returns false if not given a new email" do
      expect(jobseeker.update_email_from_govuk_one_login!(nil)).to eq(false)
    end

    it "returns false if the new email is empty" do
      expect(jobseeker.update_email_from_govuk_one_login!("")).to eq(false)
    end

    it "returns false if the new email is the same as the current email" do
      expect(jobseeker.update_email_from_govuk_one_login!(jobseeker.email)).to eq(false)
    end

    context "when the new email addres doesn't belong to other legacy jobseeker" do
      it "updates the jobseeker's email address" do
        expect { jobseeker.update_email_from_govuk_one_login!("new_email@contoso.com") }
          .to change { jobseeker.reload.email }.to("new_email@contoso.com")
      end
    end

    context "when a legacy jobseeker with the new email address already exists" do
      let!(:legacy_jobseeker) { create(:jobseeker, govuk_one_login_id: nil) }
      let(:job_application) { create(:job_application, jobseeker: legacy_jobseeker) }
      let(:profile) do
        create(:jobseeker_profile, :with_qualifications, :with_employment_history, jobseeker: legacy_jobseeker)
      end
      let(:qualifications) { profile.qualifications }
      let(:employments) { profile.employments }

      context "when the current jobseeker had no saved data" do
        it "transfers the legacy jobseeker's data to the current jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to change { jobseeker.reload.job_applications }.from([]).to([job_application])
            .and change { jobseeker.reload.jobseeker_profile }.from(nil).to(profile)
          expect(jobseeker.jobseeker_profile.qualifications).to match_array(qualifications)
          expect(jobseeker.jobseeker_profile.employments).to match_array(employments)
        end

        it "sets the jobseeker email the legacy jobseeker's email matching the GovUK OneLogin change" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to change { jobseeker.email }.to(legacy_jobseeker.email)
        end

        it "deletes the legacy jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to change(Jobseeker, :count).by(-1)
          expect { legacy_jobseeker.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the current jobseeker had recorded data data" do
        before { create(:job_application, jobseeker: jobseeker) }

        it "returns 'false'" do
          expect(jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email)).to eq(false)
        end

        it "doesn't transfer the legacy jobseeker's data to the current jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to(not_change { jobseeker.reload.jobseeker_profile })
        end

        it "doesn't update the jobseeker email" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .not_to(change { jobseeker.email })
        end

        it "doesn't delete the legacy jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .not_to(change(Jobseeker, :count))
        end
      end
    end
  end
end
