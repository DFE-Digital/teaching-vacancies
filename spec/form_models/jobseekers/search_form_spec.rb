require "rails_helper"

RSpec.describe Jobseekers::SearchForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    before { stub_const("Search::LocationBuilder::DEFAULT_RADIUS", "32") }

    context "when a radius is provided" do
      context "when a location is provided" do
        let(:params) { { radius: "1", location: "North Nowhere" } }

        it "assigns the radius attribute to the radius param" do
          expect(subject.radius).to eq("1")
        end
      end

      context "when a location is not provided" do
        let(:params) { { radius: "1" } }

        it "assigns the radius to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end
    end

    context "when a radius is not provided" do
      context "when a location is provided" do
        let(:params) { { location: "North Nowhere" } }

        it "assigns the radius attribute to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end

      context "when a location is not provided" do
        let(:params) { {} }

        it "assigns the radius to the default radius" do
          expect(subject.radius).to eq("32")
        end
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
end
