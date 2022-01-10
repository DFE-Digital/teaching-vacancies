require "rails_helper"

RSpec.describe Publishers::JobListing::JobRoleDetailsForm, type: :model do
  subject { described_class.new(vacancy:) }

  shared_examples_for "a form with send_responsible radios" do
    it { is_expected.to validate_inclusion_of(:send_responsible).in_array(%w[yes no]) }

    describe "#params_to_save" do
      before do
        subject.send_responsible = send_responsible
      end

      context "when send_responsible is `no`" do
        let(:send_responsible) { "no" }

        it "has no additional job roles" do
          expect(subject.params_to_save).to include(additional_job_roles: [])
        end
      end

      context "when send_responsible is `yes`" do
        let(:send_responsible) { "yes" }

        it "has send_responsible in the additional job roles" do
          expect(subject.params_to_save).to include(additional_job_roles: ["send_responsible"])
        end
      end
    end
  end

  context "when main job role is teacher" do
    let(:vacancy) { build(:vacancy, main_job_role: "teacher") }

    it { is_expected.not_to validate_inclusion_of(:send_responsible).in_array(%w[yes no]) }

    describe "#params_to_save" do
      let(:additional_roles) { %w[send_responsible ect_suitable] }

      it "includes additional job roles" do
        subject.additional_job_roles = additional_roles
        expect(subject.params_to_save).to include(additional_job_roles: additional_roles)
      end
    end
  end

  context "when main job role is sendco" do
    let(:vacancy) { build(:vacancy, main_job_role: "sendco") }

    it { is_expected.not_to validate_inclusion_of(:send_responsible).in_array(%w[yes no]) }
  end

  context "when main job role is leadership" do
    let(:vacancy) { build(:vacancy, main_job_role: "leadership") }

    it_behaves_like "a form with send_responsible radios"
  end

  context "when main job role is education support" do
    let(:vacancy) { build(:vacancy, main_job_role: "education_support") }

    it_behaves_like "a form with send_responsible radios"
  end
end
