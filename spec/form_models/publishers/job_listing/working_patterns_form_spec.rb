require "rails_helper"

RSpec.describe Publishers::JobListing::WorkingPatternsForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build(:vacancy) }
  let(:working_patterns) { nil }
  let(:working_patterns_details) { nil }
  let(:params) { { working_patterns:, working_patterns_details: } }

  before { subject.valid? }

  it { is_expected.to validate_presence_of(:working_patterns) }
  it { is_expected.to validate_inclusion_of(:working_patterns).in_array(Vacancy.working_patterns.keys) }

  describe "#working_patterns_details" do
    let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 50) }

    context "when working_patterns_details exceeds the maximud allowed length" do
      let(:working_patterns_details) { Faker::Lorem.sentence(word_count: 51) }

      it "ensures working_patterns_details cannot exceed 50 words" do
        expect(subject.errors.of_kind?(:working_patterns_details, :working_patterns_details_maximum_words)).to be true
      end
    end
  end
end
