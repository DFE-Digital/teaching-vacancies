require "rails_helper"

RSpec.describe ExternalVacancyValidator, type: :model do
  subject(:vacancy) { build(:vacancy, :external) }

  before { vacancy.validate }

  it "is valid with all required fields" do
    expect(vacancy).to be_valid
  end

  context "when required fields are missing" do
    before do
      vacancy.assign_attributes(
        job_title: nil,
        job_advert: nil,
        salary: nil,
        expires_at: nil,
        external_reference: nil,
        external_advert_url: nil,
        job_roles: [],
        contract_type: nil,
        phases: [],
        working_patterns: [],
        organisations: [],
      )
      vacancy.validate
    end

    it "adds errors for all missing fields" do
      expect(vacancy.errors[:job_title]).to include("can't be blank")
      expect(vacancy.errors[:job_advert]).to include("Enter a job advert")
      expect(vacancy.errors[:salary]).to include("Enter full-time salary")
      expect(vacancy.errors[:expires_at]).to include("Enter closing date")
      expect(vacancy.errors[:external_reference]).to include("Enter an external reference")
      expect(vacancy.errors[:external_advert_url]).to include("Enter an external advert URL")
      expect(vacancy.errors[:job_roles]).to include("Select a job role")
      expect(vacancy.errors[:contract_type]).to include("can't be blank")
      expect(vacancy.errors[:phases]).to include("can't be blank")
      expect(vacancy.errors[:working_patterns]).to include("Select a working pattern")
      expect(vacancy.errors[:organisations]).to include("No school(s) associated with vacancy", "can't be blank")
    end
  end

  context "when job title is too long" do
    before do
      vacancy.job_title = "A" * 76
      vacancy.validate
    end

    it "adds a job title length error" do
      expect(vacancy.errors[:job_title]).to include("must be 75 characters or fewer")
    end
  end

  context "when expiry date is today" do
    before do
      vacancy.expires_at = Time.zone.today
      vacancy.validate
    end

    it "adds an expiry date error" do
      expect(vacancy.errors[:expires_at]).to include("must be a future date")
    end
  end

  context "when expiry date is before publish date" do
    before do
      vacancy.publish_on = Date.current + 5.days
      vacancy.expires_at = Date.current + 2.days
      vacancy.validate
    end

    it "adds an expiry date vs publish date error" do
      expect(vacancy.errors[:expires_at]).to include("must be later than the publish date")
    end
  end

  describe "external reference conflict validation" do
    subject(:vacancy) { build(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:) }

    let(:publisher_ats_api_client) { create(:publisher_ats_api_client) }

    context "when there a vacancy with the same ATS client ID but with different external reference" do
      before do
        create(:vacancy, :external, external_reference: "REF456", publisher_ats_api_client:)
      end

      it "the new vacancy is valid" do
        expect(vacancy).to be_valid
      end
    end

    context "when there a vacancy with the same ATS client ID and external reference" do
      before do
        create(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:)
      end

      it "the new vacancy is invalid" do
        expect(vacancy).not_to be_valid
        expect(vacancy.errors[:external_reference])
          .to include("A vacancy with the provided ATS client ID and external reference already exists.")
      end
    end
  end

  describe "duplicate validation" do
    subject(:vacancy) do
      build(:vacancy, :external, external_reference: "REF123", publisher_ats_api_client:, organisations: [school])
    end

    let(:school) { create(:school) }
    let(:publisher_ats_api_client) { create(:publisher_ats_api_client) }

    context "when there is a vacancy with some shared info but not all required fields to be considered duplicated" do
      before do
        create(:vacancy,
               organisations: [school],
               job_title: vacancy.job_title,
               expires_at: vacancy.expires_at,
               working_patterns: vacancy.working_patterns)
      end

      it "the new vacancy is valid" do
        expect(vacancy).to be_valid
      end
    end

    context "when there is an existing vacancy sharing all required fields to be considered duplicated" do
      let(:dup_fields) do
        {
          organisations: [school],
          job_title: vacancy.job_title,
          expires_at: vacancy.expires_at,
          working_patterns: vacancy.working_patterns,
          contract_type: vacancy.contract_type,
          phases: vacancy.phases,
          salary: vacancy.salary,
        }
      end

      let(:existing_vacancy) { create(:vacancy, **dup_fields) }

      before { existing_vacancy }

      it "the new vacancy is invalid" do
        expect(vacancy).not_to be_valid
        expect(vacancy.errors[:base])
          .to include("A vacancy with the same job title, expiry date, contract type, working patterns, phases and salary already exists for this organisation.")
      end

      context "when the existing vacancy was discarded" do
        let(:existing_vacancy) { create(:vacancy, :trashed, **dup_fields) }

        it "the new vacancy is valid" do
          expect(vacancy).to be_valid
        end
      end
    end

    context "when there is an existing vacancy sharing all required fields to be considered duplicated but belongs to a different organisation" do
      before do
        create(:vacancy,
               organisations: [create(:school)],
               job_title: vacancy.job_title,
               expires_at: vacancy.expires_at,
               working_patterns: vacancy.working_patterns,
               contract_type: vacancy.contract_type,
               phases: vacancy.phases,
               salary: vacancy.salary)
      end

      it "the new vacancy is valid" do
        expect(vacancy).to be_valid
      end
    end
  end
end
