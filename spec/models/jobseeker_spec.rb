require "rails_helper"

RSpec.describe Jobseeker do
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:job_applications) }

  describe "scopes" do
    describe ".active" do
      subject(:active_jobseekers) { described_class.active }

      let(:jobseeker_active) { create(:jobseeker) }
      let(:jobseeker_inactive) { create(:jobseeker, account_closed_on: 1.day.ago) }

      it { is_expected.not_to include(jobseeker_inactive) }
      it { is_expected.to include(jobseeker_active) }
    end

    describe ".email_opt_in" do
      subject(:active_jobseekers) { described_class.email_opt_in }

      let(:jobseeker_active_opted_out) { create(:jobseeker, :email_opted_out) }
      let(:jobseeker_active_opted_in) { create(:jobseeker) }
      let(:jobseeker_inactive_opted_out) { create(:jobseeker, :email_opted_out, account_closed_on: 1.day.ago) }
      let(:jobseeker_inactive_opted_in) { create(:jobseeker, account_closed_on: 1.day.ago) }

      it { is_expected.not_to include(jobseeker_inactive_opted_out) }
      it { is_expected.not_to include(jobseeker_inactive_opted_in) }
      it { is_expected.not_to include(jobseeker_active_opted_out) }
      it { is_expected.to include(jobseeker_active_opted_in) }
    end
  end

  describe "validations" do
    describe "email_opt_out_reason" do
      let(:jobseeker) { build(:jobseeker, email_opt_out: true) }

      it "checks for reason when opting out" do
        expect(jobseeker).not_to be_valid
        expect(jobseeker.errors.messages).to eq({ email_opt_out_reason: ["Select your reason for opting out"] })
      end
    end
  end

  describe "update_subscription_emails" do
    let(:jobseeker) { create(:jobseeker) }
    let!(:subscription) { create(:subscription, email: jobseeker.email) }
    let(:new_email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

    it "updates the email address of every subscription associated with their previous email address" do
      expect {
        jobseeker.update!(email: new_email_address)
      }.to change { subscription.reload.email }.to(new_email_address)
    end
  end

  describe ".create_from_govuk_one_login" do
    subject(:create_from_govuk_one_login) do
      described_class.create_from_govuk_one_login(email: email, id: govuk_one_login_id)
    end

    let(:email) { "notarealuser121342@gmail.com" }
    let(:govuk_one_login_id) { "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4" }

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

      it_behaves_like "invalid input"
    end

    context "when no govuk_one_login_id is provided" do
      let(:govuk_one_login_id) { "" }

      it_behaves_like "invalid input"
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

    context "when the jobseeker has a different govuk_one_login_id but the provided email matches" do
      let!(:jobseeker) { create(:jobseeker, govuk_one_login_id: "id") }

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

  describe "unlink_from_govuk_one_login!" do
    it "unlinks the jobseeker from GovUK OneLogin by removing the OneLogin id" do
      jobseeker = create(:jobseeker)
      expect { jobseeker.unlink_from_govuk_one_login! }.to change { jobseeker.reload.govuk_one_login_id }.to(nil)
    end

    it "does not unlink the jobseeker if they do not have a OneLogin id" do
      jobseeker = create(:jobseeker, govuk_one_login_id: nil)
      expect { jobseeker.unlink_from_govuk_one_login! }.not_to change { jobseeker.reload.govuk_one_login_id }.from(nil)
    end
  end

  describe "update_email_from_govuk_one_login!" do
    let!(:jobseeker) { create(:jobseeker) }

    it "returns false if not given a new email" do
      expect(jobseeker.update_email_from_govuk_one_login!(nil)).to be(false)
    end

    it "returns false if the new email is empty" do
      expect(jobseeker.update_email_from_govuk_one_login!("")).to be(false)
    end

    it "returns false if the new email is the same as the current email" do
      expect(jobseeker.update_email_from_govuk_one_login!(jobseeker.email)).to be(false)
    end

    context "when the new email addres doesn't belong to other legacy jobseeker" do
      it "updates the jobseeker's email address" do
        expect { jobseeker.update_email_from_govuk_one_login!("new_email@contoso.com") }
          .to change { jobseeker.reload.email }.to("new_email@contoso.com")
      end

      it "updates the email address of every subscription associated with their previous email address" do
        subscription = create(:subscription, email: jobseeker.email)
        expect {
          jobseeker.update_email_from_govuk_one_login!("new_email@contoso.com")
        }.to change { subscription.reload.email }.to("new_email@contoso.com")
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

      RSpec.shared_examples "new jobseeker account already saved data" do
        it "returns 'false'" do
          expect(jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email)).to be(false)
        end

        it "doesn't transfer the legacy jobseeker's data to the current jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to(not_change { jobseeker.reload.jobseeker_profile })
        end

        it "doesn't update the jobseeker email" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .not_to(change(jobseeker, :email))
        end

        it "doesn't delete the legacy jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .not_to(change(described_class, :count))
        end
      end

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
            .to change(jobseeker, :email).to(legacy_jobseeker.email)
        end

        it "deletes the legacy jobseeker" do
          expect { jobseeker.update_email_from_govuk_one_login!(legacy_jobseeker.email) }
            .to change(described_class, :count).by(-1)
          expect { legacy_jobseeker.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the current jobseeker already recorded a job appplication" do
        before { create(:job_application, jobseeker: jobseeker) }

        it_behaves_like "new jobseeker account already saved data"
      end

      context "when the current jobseeker already recorded qualifications" do
        before { create(:jobseeker_profile, :with_qualifications, jobseeker: jobseeker) }

        it_behaves_like "new jobseeker account already saved data"
      end

      context "when the current jobseeker already recorded employment history" do
        before { create(:jobseeker_profile, :with_employment_history, jobseeker: jobseeker) }

        it_behaves_like "new jobseeker account already saved data"
      end
    end
  end

  describe "#papertrail_display_name" do
    subject { jobseeker.papertrail_display_name }

    context("without profile") do
      let(:jobseeker) { build_stubbed(:jobseeker) }

      it { is_expected.to eq("Jobseeker") }
    end

    context("with details") do
      let(:first) { "First" }
      let(:last) { "Last" }
      let(:jobseeker) do
        build_stubbed(:jobseeker,
                      jobseeker_profile: build_stubbed(:jobseeker_profile,
                                                       personal_details: build_stubbed(:personal_details, first_name: first, last_name: last)))
      end

      it { is_expected.to eq("First Last") }
    end
  end

  describe "#has_submitted_native_job_application?" do
    let(:jobseeker) { create(:jobseeker) }
    let(:vacancy) { create(:vacancy) }

    context "when jobseeker has a submitted native job application" do
      before do
        create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy)
      end

      it "returns true" do
        expect(jobseeker.has_submitted_native_job_application?).to be(true)
      end
    end

    context "when jobseeker has only a draft native job application" do
      before do
        create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy)
      end

      it "returns false" do
        expect(jobseeker.has_submitted_native_job_application?).to be(false)
      end
    end

    context "when jobseeker has no job applications" do
      it "returns false" do
        expect(jobseeker.has_submitted_native_job_application?).to be(false)
      end
    end

    context "when jobseeker has only an uploaded job application" do
      before do
        create(:uploaded_job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy)
      end

      it "returns false" do
        expect(jobseeker.has_submitted_native_job_application?).to be(false)
      end
    end
  end
end
