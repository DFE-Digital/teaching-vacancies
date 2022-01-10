require "rails_helper"

RSpec.describe AbTests do
  subject { described_class.new(session, test_configuration:) }

  let(:session) { {} }
  let(:test_configuration) do
    {
      test_one: {
        blue: 3,
        red: 2,
        yellow: 1,
      },
      test_two: {
        yes: 1,
        no: 1,
      },
    }
  end

  around do |example|
    # Ensure we always get the same "random" choice by seeding Ruby's random number generator,
    # returning it to the RSpec seed after (so as to not affect other specs)
    srand(42)
    example.run
    srand(RSpec.configuration.seed)
  end

  describe "#current_variants" do
    context "when no tests are set in the session yet" do
      let(:session) { {} }
      let(:expected_variants) { { test_one: :red, test_two: :yes } }

      it "creates the session cache and populates it with variants" do
        expect(subject.current_variants).to eq(expected_variants)
        expect(session[:ab_tests]).to eq(expected_variants)
      end
    end

    context "when some tests are set in the session already" do
      let(:session) { { ab_tests: { test_two: :no } } }
      let(:expected_variants) { { test_one: :red, test_two: :no } }

      it "populates missing variants in the session cache" do
        expect(subject.current_variants).to eq(expected_variants)
        expect(session[:ab_tests]).to eq(expected_variants)
      end
    end
  end

  describe "#variant_for" do
    it "returns the variant for the requested test" do
      expect(subject.variant_for(:test_one)).to eq(:red)
    end

    it "errors when requesting a non-existent variant" do
      expect { subject.variant_for(:test_three) }.to raise_error(ArgumentError, /not configured/)
    end
  end
end
