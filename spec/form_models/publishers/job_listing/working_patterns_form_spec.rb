require "rails_helper"

RSpec.describe Publishers::JobListing::WorkingPatternsForm, type: :model do
  subject(:form) { described_class.new(params, vacancy) }

  let(:vacancy) { build(:vacancy) }
  let(:working_patterns) { nil }
  let(:working_patterns_details) { nil }
  let(:params) { { working_patterns:, working_patterns_details: } }

  before { subject.valid? }

  it { is_expected.to validate_presence_of(:working_patterns) }
  it { is_expected.to validate_inclusion_of(:working_patterns).in_array(Vacancy.working_patterns.keys - ["job_share"]) }

  it "validates 'is_job_share' presence" do
    expect(form).not_to be_valid
    expect(form.errors[:is_job_share]).to eq(["Select yes if this role can be done as a job share"])
  end

  describe "'is_job_share' validation" do
    it "errors when not answered" do
      expect(form).not_to be_valid
      expect(form.errors[:is_job_share]).to eq(["Select yes if this role can be done as a job share"])
    end

    it "accepts 'true' as an answer" do
      form.is_job_share = true
      form.validate
      expect(form.errors[:is_job_share]).to be_empty
    end

    it "accepts 'false' as an answer" do
      form.is_job_share = false
      form.validate
      expect(form.errors[:is_job_share]).to be_empty
    end
  end

  describe "#working_patterns_details" do
    context "when working_patterns_details does not exceed the maximum allowed length" do
      let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 75) }

      it { is_expected.to allow_value(working_patterns_details).for(:working_patterns_details) }
    end

    context "when working_patterns_details exceeds the maximud allowed length" do
      let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 76) }

      it "ensures working_patterns_details cannot exceed 75 words" do
        expect(form.errors.of_kind?(:working_patterns_details, :working_patterns_details_maximum_words)).to be true
      end
    end
  end
end
