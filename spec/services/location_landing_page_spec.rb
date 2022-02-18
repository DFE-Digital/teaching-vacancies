require "rails_helper"

RSpec.describe LocationLandingPage do
  subject { described_class["narnia"] }

  before do
    stub_const("ALL_IMPORTED_LOCATIONS", %w[narnia])
  end

  let(:search) { instance_double(Search::VacancySearch, total_count: 34) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(location: "Narnia"))
      .and_return(search)
  end

  describe ".exists?" do
    it "returns whether a landing page exists for the given location name" do
      expect(described_class.exists?("narnia")).to be(true)
      expect(described_class.exists?("Narnia")).to be(false)
      expect(described_class.exists?("blahrnia")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a configured landing page instance if a location polygon with the given name exists" do
      expect(described_class["narnia"].name).to eq("Narnia")
      expect(described_class["narnia"].criteria).to eq({ location: "Narnia" })
    end

    it "raises an error if no landing page with the given slug has been configured" do
      expect { described_class["shmarnia"] }
        .to raise_error("No such location landing page: 'shmarnia'")
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(subject.count).to eq(34)
    end
  end

  describe "i18n methods" do
    specify { expect(subject.heading).to eq(I18n.t("landing_pages._location.heading", location: "Narnia", count: "<span class=\"govuk-!-font-weight-bold\">34</span>")) }
    specify { expect(subject.meta_description).to eq(I18n.t("landing_pages._location.meta_description", location: "Narnia")) }
    specify { expect(subject.name).to eq("Narnia") }
    specify { expect(subject.title).to eq(I18n.t("landing_pages._location.title", location: "Narnia")) }
  end
end
