require "rails_helper"

RSpec.describe Resettable do
  context "inclusion" do
    let(:vacancy) { build(:vacancy) }

    it { expect(vacancy).to respond_to(:reset_dependent_fields) }
  end

  context "when changing working patterns" do
    subject(:update_working_patterns) { vacancy.update(working_patterns: %w[full_time]) }

    let(:vacancy) { build(:vacancy, working_patterns: %w[part_time]) }
    let(:previous_actual_salary) { vacancy.actual_salary }

    it "resets actual salary" do
      expect { update_working_patterns }
        .to change { vacancy.actual_salary }
        .from(previous_actual_salary).to("")
    end
  end

  context "when changing contract type" do
    subject(:update_contract_type) { vacancy.update(contract_type: "permanent") }

    let(:vacancy) { build(:vacancy, contract_type: contract_type) }
    let(:previous_fixed_term_contract_duration) { vacancy.fixed_term_contract_duration }

    context "from fixed term" do
      let(:contract_type) { "fixed_term" }

      it "resets fixed term contract duration" do
        expect { update_contract_type }
          .to change { vacancy.fixed_term_contract_duration }
          .from(previous_fixed_term_contract_duration).to("")
      end
    end
  end

  context "when changing education support" do
    subject(:update_education_support) { vacancy.update(job_roles: ["education_support"]) }

    let(:vacancy) { build(:vacancy, phases: %w[primary], job_roles: ["teacher"], key_stages: %w[ks1]) }
    let(:previous_key_stages) { vacancy.key_stages }

    it "resets key stages" do
      expect { update_education_support }
        .to change { vacancy.key_stages }
        .from(previous_key_stages).to([])
    end
  end

  context "when changing education phases" do
    subject(:update_education_phases) { vacancy.update(phases: updated_phases) }

    let(:vacancy) { build(:vacancy, :secondary) }
    let(:previous_subjects) { vacancy.subjects }
    let(:previous_key_stages) { vacancy.key_stages }

    context "to primary school" do
      let(:updated_phases) { %w[primary] }

      it "resets subjects" do
        expect { update_education_phases }
          .to change { vacancy.subjects }
          .from(previous_subjects).to([])
      end
    end

    context "to nursery" do
      let(:updated_phases) { %w[nursery] }

      it "resets key stages" do
        expect { update_education_phases }
          .to change { vacancy.key_stages }
          .from(previous_key_stages).to(%w[early_years])
      end
    end
  end

  context "when changing job role" do
    subject(:update_job_role) { vacancy.update(job_roles: ["education_support"]) }

    let(:vacancy) { build(:vacancy, job_roles: ["teacher"]) }
    let(:previous_ect_status) { vacancy.ect_status }

    it "resets the ect status" do
      expect { update_job_role }
        .to change { vacancy.ect_status }
        .from(previous_ect_status).to(nil)
    end
  end

  context "when changing enable job applications" do
    let(:vacancy) do
      create(:draft_vacancy, :no_tv_applications)
    end

    it "resets receive application" do
      expect { vacancy.update!(enable_job_applications: true) }
        .to change { vacancy.reload.receive_applications }
        .from("website").to(nil)
    end
  end

  context "when changing receive application" do
    subject(:update_receive_application) { vacancy.update!(receive_applications: new_receive_applications, application_link: Faker::Internet.url) }

    context "from email to website" do
      let(:vacancy) { build(:vacancy, enable_job_applications: false, receive_applications: "email", application_email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)) }
      let(:new_receive_applications) { "website" }
      let(:previous_application_email) { vacancy.application_email }

      it "resets application email" do
        expect { update_receive_application }
        .to change { vacancy.application_email }
        .from(previous_application_email).to(nil)
      end
    end

    context "from website to email" do
      let(:vacancy) { build(:vacancy, enable_job_applications: false, receive_applications: "website", application_link: "www.test.com") }
      let(:new_receive_applications) { "email" }
      let(:previous_application_link) { vacancy.application_link }

      it "resets application link" do
        expect { update_receive_application }
          .to change { vacancy.application_link }
          .from(previous_application_link).to("")
      end
    end
  end

  context "when changing additional documents" do
    let(:vacancy) { build(:vacancy, :with_supporting_documents) }
    let(:previous_supporting_documents) { vacancy.supporting_documents }
    let(:document) { double("ActiveRecordStorage", purge_later: nil) }

    before do
      allow(vacancy).to receive(:supporting_documents).and_return([document])
      vacancy.update(include_additional_documents: false)
    end

    it "removes all previous supporting documents" do
      expect(vacancy.supporting_documents).to all(have_received(:purge_later))
    end
  end

  context "when changing contact number provided" do
    subject(:update_contact_number_provided) { vacancy.update(contact_number_provided: false) }

    let(:vacancy) { build(:vacancy, contact_number_provided: true, contact_number: "1111111111") }
    let(:previous_contact_number) { vacancy.contact_number }

    it "resets contact number" do
      expect { update_contact_number_provided }
        .to change { vacancy.contact_number }
        .from(previous_contact_number).to(nil)
    end
  end

  context "when changing further details provided" do
    subject(:update_further_details_provided) { vacancy.update(further_details_provided: false) }

    let(:vacancy) { build(:vacancy, further_details_provided: true, further_details: "test") }
    let(:previous_further_details) { vacancy.further_details }

    it "resets further details" do
      expect { update_further_details_provided }
        .to change { vacancy.further_details }
        .from(previous_further_details).to(nil)
    end
  end

  context "when changing benefits" do
    subject(:update_benefits) { vacancy.update(benefits: false) }

    let(:vacancy) { build(:vacancy, benefits: true, benefits_details: "test") }
    let(:previous_benefits_details) { vacancy.benefits_details }

    it "resets benefits details" do
      expect { update_benefits }
        .to change { vacancy.benefits_details }
        .from(previous_benefits_details).to(nil)
    end
  end
end
