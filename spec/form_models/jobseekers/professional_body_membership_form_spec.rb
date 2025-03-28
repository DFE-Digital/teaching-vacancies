require "rails_helper"

RSpec.describe Jobseekers::ProfessionalBodyMembershipForm, type: :model do
  subject(:form) do
    described_class.new(
      name: name,
      membership_type: membership_type,
      membership_number: membership_number,
      year_membership_obtained: year_membership_obtained,
      exam_taken: exam_taken,
    )
  end

  let(:name) { "Sample Body" }
  let(:membership_type) { "Full Membership" }
  let(:membership_number) { "12345" }
  let(:year_membership_obtained) { Time.zone.today }
  let(:exam_taken) { true }

  describe "validations" do
    context "when all attributes are valid" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when name is not present" do
      let(:name) { nil }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors[:name]).to include("Enter the name of the professional body.")
      end
    end

    context "when exam_taken is not present" do
      let(:exam_taken) { nil }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors[:exam_taken]).to include("Select yes if your professional body membership required you to take an exam.")
      end
    end

    context "when only attributes present are name and exam_taken" do
      let(:form) { described_class.new(name: name, exam_taken: exam_taken) }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when exam_taken is true or false" do
      it "is valid with true" do
        form.exam_taken = true
        expect(form).to be_valid
      end

      it "is valid with false" do
        form.exam_taken = false
        expect(form).to be_valid
      end
    end
  end
end
