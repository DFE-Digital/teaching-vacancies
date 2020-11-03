require "rails_helper"

RSpec.describe SchoolsForm, type: :model do
  let(:subject) { described_class.new(params) }

  describe "#validations" do
    context "when job_location is at_one_school" do
      let(:params) { { job_location: job_location, organisation_id: organisation_id } }
      let(:job_location) { "at_one_school" }

      context "when organisation_id is blank" do
        let(:organisation_id) { nil }

        it "requires a school to be selected" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:organisation_id]).to eql([I18n.t("schools_errors.organisation_id.blank")])
        end
      end

      context "when organisation_id is present" do
        let(:organisation_id) { "school_id" }

        it "is valid" do
          expect(subject.valid?).to be true
          expect(subject.organisation_id).to eql("school_id")
        end
      end
    end

    context "when job_location is at_multiple_schools" do
      let(:params) { { job_location: job_location, organisation_ids: organisation_ids } }
      let(:job_location) { "at_multiple_schools" }

      context "when organisation_ids is blank" do
        let(:organisation_ids) { nil }

        it "requires at least 2 schools to be selected" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:organisation_ids]).to eql([I18n.t("schools_errors.organisation_ids.blank")])
        end
      end

      context "when less than 2 organisations are selected" do
        let(:organisation_ids) { %w[school_1_id] }

        it "requires at least 2 schools to be selected" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:organisation_ids]).to eql([I18n.t("schools_errors.organisation_ids.invalid")])
        end
      end

      context "when 2 or more organisations are selected" do
        let(:organisation_ids) { %w[school_1_id school_2_id] }

        it "is valid" do
          expect(subject.valid?).to be true
          expect(subject.organisation_ids).to eql(%w[school_1_id school_2_id])
        end
      end
    end
  end
end
