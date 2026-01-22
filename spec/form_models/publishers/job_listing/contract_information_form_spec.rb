require "rails_helper"

RSpec.describe Publishers::JobListing::ContractInformationForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:vacancy) { build(:vacancy) }
  let(:working_patterns) { nil }
  let(:working_patterns_details) { nil }
  let(:contract_type) { nil }
  let(:params) { { working_patterns:, working_patterns_details:, contract_type: } }

  before { form.valid? }

  it { is_expected.to validate_presence_of(:working_patterns) }
  it { is_expected.to validate_inclusion_of(:working_patterns).in_array(Vacancy::WORKING_PATTERNS) }
  it { is_expected.to validate_inclusion_of(:contract_type).in_array(Vacancy.contract_types.keys).with_message("Select contract type") }

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

  describe "fixed_term_contract_duration validation" do
    context "when contract_type is fixed_term" do
      let(:contract_type) { "fixed_term" }

      it "is invalid without fixed_term_contract_duration" do
        form.fixed_term_contract_duration = nil
        form.validate
        expect(form.errors[:fixed_term_contract_duration]).to include("Enter the length of the fixed term contract")
      end

      it "is valid with a fixed_term_contract_duration" do
        form.fixed_term_contract_duration = "6 months"
        form.validate
        expect(form.errors[:fixed_term_contract_duration]).to be_empty
      end
    end
  end

  describe "is_parental_leave_cover validation" do
    context "when contract_type is fixed_term" do
      let(:contract_type) { "fixed_term" }

      it "is invalid without is_parental_leave_cover being true or false" do
        form.is_parental_leave_cover = nil
        form.validate
        expect(form.errors[:is_parental_leave_cover]).to include("Select yes if this role is covering maternity or paternity leave")
      end

      it "is valid when is_parental_leave_cover is true" do
        form.is_parental_leave_cover = true
        form.validate
        expect(form.errors[:is_parental_leave_cover]).to be_empty
      end

      it "is valid when is_parental_leave_cover is false" do
        form.is_parental_leave_cover = false
        form.validate
        expect(form.errors[:is_parental_leave_cover]).to be_empty
      end
    end
  end
end
