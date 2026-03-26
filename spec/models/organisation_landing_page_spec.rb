require "rails_helper"

RSpec.describe OrganisationLandingPage do
  subject(:landing_page) { described_class["test-organisation-slug"] }

  let(:organisation) { instance_double(Organisation, name: "Test Organisation", slug: "test-organisation-slug") }
  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(organisation_slug: "test-organisation-slug"))
      .and_return(search)

    # rubocop:disable RSpec/MessageChain
    allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(true)
    allow(Organisation).to receive_message_chain(:friendly, :find).and_return(organisation)
    # rubocop:enable RSpec/MessageChain
  end

  describe ".exists?" do
    context "when the organisation exists" do
      it "returns true" do
        expect(described_class.exists?("test-organisation-slug")).to be(true)
      end
    end

    context "when the organisation does not exist" do
      before do
        # rubocop:disable RSpec/MessageChain
        allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(false)
        # rubocop:enable RSpec/MessageChain
      end

      it "returns false" do
        expect(described_class.exists?("test-organisation-slug")).to be(false)
      end
    end
  end

  describe ".[]" do
    context "when the organisation exists" do
      it "returns a configured organisation landing page instance" do
        expect(landing_page.name).to eq(organisation.name)
        expect(landing_page.criteria).to eq({ organisation_slug: "test-organisation-slug" })
      end
    end

    context "when the organisation does not exist" do
      before do
        # rubocop:disable RSpec/MessageChain
        allow(Organisation).to receive_message_chain(:friendly, :exists?).and_return(false)
        # rubocop:enable RSpec/MessageChain
      end

      it "raises an error" do
        expect { described_class["wrong-organisation-slug"] }
          .to raise_error("No such organisation landing page: 'wrong-organisation-slug'")
      end
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(landing_page.count).to eq(42)
    end
  end

  describe "i18n methods" do
    specify { expect(landing_page.heading).to eq(I18n.t("landing_pages._organisation.heading", organisation: "Test Organisation", count: "42")) }
    specify { expect(landing_page.meta_description).to eq(I18n.t("landing_pages._organisation.meta_description", organisation: "Test Organisation")) }
    specify { expect(landing_page.name).to eq("Test Organisation") }
    specify { expect(landing_page.title).to eq(I18n.t("landing_pages._organisation.title", organisation: "Test Organisation")) }
  end
end
