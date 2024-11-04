require "rails_helper"

RSpec.describe CampaignPage do
  subject(:campaign_page) { described_class["FAKE1+CAMPAIGN"] }

  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
            .with(hash_including(working_patterns: %w[part_time], subjects: %w[Potions Sorcery]))
            .and_return(search)
  end

  describe ".exists?" do
    it "returns whether a landing page has been set up" do
      expect(described_class.exists?("FAKE1+CAMPAIGN")).to be(true)
      expect(described_class.exists?("i-do-not-exist")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a configured landing page instance if a landing page with the given slug exists" do
      expect(described_class["FAKE1+CAMPAIGN"].banner_image)
        .to eq("campaigns/secondary_not_too_late.jpg")
      expect(described_class["FAKE1+CAMPAIGN"].criteria)
        .to eq({ radius: 15, teaching_job_roles: %w[teacher], working_patterns: %w[part_time], subjects: %w[Potions Sorcery] })
    end

    it "raises an error if no landing page with the given slug has been configured" do
      expect { described_class["i-do-not-exist"] }
        .to raise_error("No such campaign page: 'i-do-not-exist'")
    end
  end

  describe "banner_title" do
    it "returns the banner title" do
      expect(campaign_page.banner_title("Severus")).to eq("Severus, this is a fake campaign")
    end
  end
end
