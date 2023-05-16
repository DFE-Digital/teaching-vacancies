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
    let(:params) { { keyword: keyword, previous_keyword: previous_keyword, landing_page: landing_page, phases: phases } }

    context "when landing_page is not present" do
      let(:keyword) { "biology" }
      let(:previous_keyword) { "" }
      let(:landing_page) { "" }
      let(:phases) { [] }

      it "sets the filters from the keyword" do
        expect(subject.phases).to eq %w[secondary sixth_form_or_college]
      end
    end

    context "when landing_page is present" do
      let(:keyword) { "biology" }
      let(:previous_keyword) { "" }
      let(:landing_page) { "landing_page" }
      let(:phases) { %w[middle_school] }

      it "does not set the filters from the keyword" do
        expect(subject.phases).to eq %w[middle_school]
      end
    end

    context "when keyword is the same as previous_keyword" do
      let(:keyword) { "biology" }
      let(:previous_keyword) { "biology" }
      let(:landing_page) { "" }
      let(:phases) { %w[middle_school] }

      it "does not set the filters from the keyword" do
        expect(subject.phases).to eq %w[middle_school]
      end
    end
  end

  describe "#unset_filters_from_previous_keyword" do
    let(:params) { { keyword: keyword, previous_keyword: previous_keyword, phases: phases } }

    context "when keyword is blank and previous_keyword is present" do
      let(:keyword) { "" }
      let(:previous_keyword) { "biology" }
      let(:phases) { %w[secondary sixth_form_or_college] }

      it "unsets the filters set from the previous keyword" do
        expect(subject.phases).to eq []
      end
    end
  end
end
