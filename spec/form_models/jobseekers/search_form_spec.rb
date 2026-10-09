require "rails_helper"

RSpec.describe Jobseekers::SearchForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:radius_builder) { instance_double(Search::RadiusBuilder) }
    let(:expected_radius) { 1000 }
    let(:params) { { radius: radius, location: location } }

    before { allow(radius_builder).to receive(:radius).and_return(expected_radius) }

    context "when location param is provided" do
      let(:location) { "North Nowhere" }

      context "when radius param is provided" do
        let(:radius) { "1" }

        it_behaves_like "a correct call of Search::RadiusBuilder"
      end

      context "when radius param is not provided" do
        let(:radius) { nil }

        it_behaves_like "a correct call of Search::RadiusBuilder"
      end
    end

    context "when location param is not provided" do
      let(:location) { nil }

      context "when radius param is provided" do
        let(:radius) { "1" }

        it_behaves_like "a correct call of Search::RadiusBuilder"
      end

      context "when radius param is not provided" do
        let(:radius) { nil }

        it_behaves_like "a correct call of Search::RadiusBuilder"
      end
    end
  end

  RSpec.shared_examples "a set filter for jobseeker" do |field|
    let(:expected) { ["field_#{field}"] }
    let(field) { expected }
    let(:params) do
      {
        field => expected,
      }
    end

    it { is_expected.to eq({ field => expected }) }
  end

  describe "#filters" do
    subject { described_class.new(params).filters }

    let(:params) { {} }

    context "when no filters set" do
      it { is_expected.to eq({}) }
    end

    %i[
      visa_sponsorship_availability
      teaching_job_roles
      support_job_roles
      phases
      subjects
      ect_statuses
      organisation_types
      school_types
      working_patterns
      quick_apply
    ].each do |field|
      context "when #{field} filters set" do
        it_behaves_like "a set filter for jobseeker", field
      end
    end
  end

  describe "#strip_trailing_whitespaces_from_params" do
    context "when user input contains trailing whitespace" do
      let(:keyword) { " teacher " }
      let(:location) { "the big smoke " }
      let(:params) { { keyword: keyword, location: location } }

      it "strips the whitespace before saving the attribute" do
        expect(subject.keyword).to eq "teacher"
        expect(subject.location).to eq "the big smoke"
      end
    end
  end

  describe "#subject_options" do
    let(:params) { {} }

    it "includes further education subjects" do
      expect(subject.subject_options).to include(["Animal care", ""])
    end

    it "does not include duplicate subject labels" do
      subject_names = subject.subject_options.map(&:first)

      expect(subject_names.map(&:downcase)).to eq(subject_names.map(&:downcase).uniq)
    end
  end

  describe "#organisation_type_options" do
    let(:params) { {} }

    it "includes colleges" do
      expect(subject.organisation_type_options).to include(["FE Colleges", nil])
    end
  end
end
