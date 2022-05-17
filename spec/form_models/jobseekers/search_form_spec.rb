require "rails_helper"

RSpec.describe Jobseekers::SearchForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:radius_builder) { instance_double(Search::RadiusBuilder) }
    let(:expected_radius) { "1000" }
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

    context "when the transportation_type and travel_time params have been provided" do
      let(:params) { { radius: "10", location: "London", transportation_type: "public_transport", travel_time: "45" } }

      it "sets the radius to 0" do
        expect(subject.radius).to eq 0
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

  describe "#set_filters_from_keyword" do
    let(:params) { { keyword: keyword, previous_keyword: previous_keyword, landing_page: landing_page, subjects: subjects } }

    context "when landing_page is not present" do
      let(:keyword) { "math" }
      let(:previous_keyword) { "" }
      let(:landing_page) { "" }
      let(:subjects) { %w[Mathematics Statistics] }

      it "sets the filters from the keyword" do
        expect(subject.subjects).to eq %w[Mathematics Statistics]
      end
    end

    context "when landing_page is present" do
      let(:keyword) { "math" }
      let(:previous_keyword) { "" }
      let(:landing_page) { "landing_page" }
      let(:subjects) { %w[Computing] }

      it "does not set the filters from the keyword" do
        expect(subject.subjects).to eq %w[Computing]
      end
    end

    context "when keyword is the same as previous_keyword" do
      let(:keyword) { "math" }
      let(:previous_keyword) { "math" }
      let(:landing_page) { "" }
      let(:subjects) { %w[Computing] }

      it "does not set the filters from the keyword" do
        expect(subject.subjects).to eq %w[Computing]
      end
    end
  end

  describe "#unset_filters_from_previous_keyword" do
    let(:params) { { keyword: keyword, previous_keyword: previous_keyword, subjects: subjects } }

    context "when keyword is blank and previous_keyword is present" do
      let(:keyword) { "" }
      let(:previous_keyword) { "maths" }
      let(:subjects) { %w[Mathematics Statistics] }

      it "unsets the filters set from the previous keyword" do
        expect(subject.subjects).to eq []
      end
    end
  end
end
