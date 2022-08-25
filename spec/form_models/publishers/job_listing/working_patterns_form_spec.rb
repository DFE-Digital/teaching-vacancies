require "rails_helper"

RSpec.describe Publishers::JobListing::WorkingPatternsForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build(:vacancy) }
  let(:working_patterns) { nil }
  let(:full_time_details) { nil }
  let(:part_time_details) { nil }
  let(:params) do
    {
      working_patterns: working_patterns,
      full_time_details: full_time_details,
      part_time_details: part_time_details,
    }
  end

  before { subject.valid? }

  it { is_expected.to validate_presence_of(:working_patterns) }

  # TODO: Working Patterns: Remove call to #reject once all vacancies with legacy working patterns have expired
  it { is_expected.to validate_inclusion_of(:working_patterns).in_array(Vacancy.working_patterns.keys.reject { |working_pattern| working_pattern.in?(%w[flexible job_share term_time]) }) }

  describe "#full_time_details" do
    let(:full_time_details) { Faker::Lorem.sentence(word_count: 50) }

    context "when validating the presence of full_time_details" do
      context "when the working patterns include full_time" do
        let(:working_patterns) { %w[full_time] }

        it { is_expected.to validate_presence_of(:full_time_details) }
      end

      context "when the working patterns do not include full_time" do
        let(:working_patterns) { %w[part_time] }

        it { is_expected.to_not validate_presence_of(:full_time_details) }
      end
    end

    context "when validating the length of full_time_details" do
      let(:full_time_details) { Faker::Lorem.sentence(word_count: 51) }

      context "when the working patterns include full_time" do
        let(:working_patterns) { %w[full_time] }

        it "ensures full_time_details cannot exceed 50 words" do
          expect(subject.errors.of_kind?(:full_time_details, :full_time_details_maximum_words)).to be true
        end
      end

      context "when the working patterns do not include full_time" do
        let(:working_patterns) { %w[part_time] }

        it "does not validate the length of full_time_details" do
          expect(subject.errors.of_kind?(:full_time_details, :full_time_details_maximum_words)).to be false
        end
      end
    end
  end

  describe "#part_time_details" do
    let(:part_time_details) { Faker::Lorem.sentence(word_count: 50) }

    context "when validating the presence of part_time_details" do
      context "when the working patterns include part_time" do
        let(:working_patterns) { %w[part_time] }

        it { is_expected.to validate_presence_of(:part_time_details) }
      end

      context "when the working patterns do not include part_time" do
        let(:working_patterns) { %w[full_time] }

        it { is_expected.to_not validate_presence_of(:part_time_details) }
      end
    end

    context "when validating the length of part_time_details" do
      let(:part_time_details) { Faker::Lorem.sentence(word_count: 51) }

      context "when the working patterns include part_time" do
        let(:working_patterns) { %w[part_time] }

        it "ensures part_time_details cannot exceed 50 words" do
          expect(subject.errors.of_kind?(:part_time_details, :part_time_details_maximum_words)).to be true
        end
      end

      context "when the working patterns do not include part_time" do
        let(:working_patterns) { %w[full_time] }

        it "does not validate the length of part_time_details" do
          expect(subject.errors.of_kind?(:part_time_details, :part_time_details_maximum_words)).to be false
        end
      end
    end
  end

  describe "#params_to_save" do
    context "when the details' associated working pattern is in working_patterns" do
      let(:full_time_details) { "Some details" }
      let(:working_patterns) { %w[full_time] }

      it "sets the working pattern's details correctly" do
        expect(subject.params_to_save[:full_time_details]).to eq(full_time_details)
      end
    end

    context "when the details' associated working pattern is not in working_patterns" do
      let(:working_patterns) { %w[full_time] }
      let(:part_time_details) { "Some other details" }

      it "sets the missing working pattern's details to nil in the params" do
        expect(subject.params_to_save[:part_time_details]).to be nil
      end
    end
  end
end
