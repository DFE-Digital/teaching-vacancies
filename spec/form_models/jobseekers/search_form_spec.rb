require "rails_helper"

RSpec.describe Jobseekers::SearchForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:radius_builder) { instance_double(Search::RadiusBuilder) }
    let(:expected_radius) { "1000" }
    let(:params) { { radius:, location: } }

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

  describe "#strip_trailing_whitespaces_from_params" do
    context "when user input contains trailing whitespace" do
      let(:keyword) { " teacher " }
      let(:location) { "the big smoke " }
      let(:params) { { keyword:, location: } }

      it "strips the whitespace before saving the attribute" do
        expect(subject.keyword).to eq "teacher"
        expect(subject.location).to eq "the big smoke"
      end
    end
  end
end
