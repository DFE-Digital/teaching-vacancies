require "rails_helper"

RSpec.describe SchoolSearchForm, type: :model do
  let(:school_search_form) { described_class.new(params) }
  let(:params) do
    {
      location: location,
      radius: radius,
      education_phase: education_phase,
      key_stage: key_stage,
      special_school: special_school,
      job_availability: job_availability,
      organisation_types: organisation_types,
      school_types: school_types,
    }
  end

  let(:location) { nil }
  let(:radius) { nil }
  let(:education_phase) { [] }
  let(:key_stage) { [] }
  let(:special_school) { [] }
  let(:job_availability) { [] }
  let(:organisation_types) { [] }
  let(:school_types) { [] }

  describe "#job_availability_options" do
    subject { school_search_form.job_availability_options }

    let(:expected_options) do
      [["true", I18n.t(true, scope: "organisations.filters.job_availability.options")]]
    end

    it { is_expected.to match_array(expected_options) }
  end

  describe "#to_h" do
    subject { school_search_form.to_h }

    context "when no params" do
      let(:expected_hash) { {} }

      it { is_expected.to eq(expected_hash) }
    end

    context "when location present" do
      let(:location) { "Nottingham" }
      let(:expected_hash) do
        {
          location: location,
          radius: 15,
        }
      end

      it { is_expected.to eq(expected_hash) }
    end

    context "when location and radius present" do
      let(:location) { "Nottingham" }
      let(:radius) { 5 }
      let(:expected_hash) do
        {
          location: location,
          radius: radius,
        }
      end

      it { is_expected.to eq(expected_hash) }
    end

    context "when job_availability present" do
      let(:job_availability) { %w[true] }
      let(:expected_hash) do
        {
          job_availability: job_availability,
        }
      end

      it { is_expected.to eq(expected_hash) }
    end
  end
end
