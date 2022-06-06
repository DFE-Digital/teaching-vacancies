require "rails_helper"

RSpec.describe OrganisationLandingPage do
  subject { described_class["test-organisation-slug"] }

  let(:organisation) { instance_double(Organisation, name: "Test Organisation", slug: "test-organisation-slug") }
  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(organisation_slug: "test-organisation-slug"))
      .and_return(search)

    allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(true)
    allow(Organisation).to receive_message_chain(:friendly, :find).and_return(organisation)
  end

  describe ".exists?" do
    context "when the organisation exists" do
      it "returns true" do
        expect(described_class.exists?("test-organisation-slug")).to be(true)
      end
    end

    context "when the organisation does not exist" do
      before { allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(false) }

      it "returns false" do
        expect(described_class.exists?("test-organisation-slug")).to be(false)
      end
    end
  end

  describe ".[]" do
    context "when the organisation exists" do
      it "returns a configured organisation landing page instance" do
        expect(subject.name).to eq(organisation.name)
        expect(subject.criteria).to eq({ organisation_slug: "test-organisation-slug" })
      end
    end

    context "when the organisation does not exist" do
      before do
        allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(false)
      end

      it "raises an error" do
        expect { described_class["wrong-organisation-slug"] }
          .to raise_error("No such organisation landing page: 'wrong-organisation-slug'")
      end
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(subject.count).to eq(42)
    end
  end

  describe "i18n methods" do
    specify { expect(subject.heading).to eq(I18n.t("landing_pages._organisation.heading", organisation: "Test Organisation", count: "<span class=\"govuk-!-font-weight-bold\">42</span>")) }
    specify { expect(subject.meta_description).to eq(I18n.t("landing_pages._organisation.meta_description", organisation: "Test Organisation")) }
    specify { expect(subject.name).to eq("Test Organisation") }
    specify { expect(subject.title).to eq(I18n.t("landing_pages._organisation.title", organisation: "Test Organisation")) }
  end
end
