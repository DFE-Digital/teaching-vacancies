require "rails_helper"

RSpec.describe VacancyFacets do
  subject { described_class.new }

  let(:search_builder) { instance_double(Search::SearchBuilder, stats: [42]) }

  before do
    allow(Rails.application.config.action_controller).to receive(:perform_caching).and_return(true)
    allow(Search::SearchBuilder).to receive(:new).and_return(search_builder)
  end

  describe "#job_roles" do
    it "returns the expected facets" do
      expect(subject.job_roles.values.uniq).to eq([42])
    end
  end

  describe "#subjects" do
    it "returns the expected facets" do
      expect(subject.subjects.values.uniq).to eq([42])
    end
  end

  describe "#cities" do
    it "returns the expected facets" do
      expect(subject.cities.values.uniq).to eq([42])
    end
  end

  describe "#counties" do
    it "returns the expected facets" do
      expect(subject.counties.values.uniq).to eq([42])
    end
  end

  context "when caching is disabled" do
    before do
      allow(Rails.application.config.action_controller).to receive(:perform_caching).and_return(false)
    end

    describe "#job_roles" do
      it "does not perform a search" do
        expect(subject.job_roles.values.uniq).to be_empty
      end
    end

    describe "#subjects" do
      it "does not perform a search" do
        expect(subject.subjects.values.uniq).to be_empty
      end
    end

    describe "#cities" do
      it "does not perform a search" do
        expect(subject.cities.values.uniq).to be_empty
      end
    end

    describe "#counties" do
      it "does not perform a search" do
        expect(subject.counties.values.uniq).to be_empty
      end
    end
  end
end
