require "rails_helper"

# This spec relies on a fake landing page set up in the test section of `config/landing_pages.yml`
# and the translation file.
RSpec.describe LandingPage do
  subject(:landing_page) { described_class["teaching-assistant-jobs-v2"] }

  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(
              hidden_filters: %w[visa_sponsorship teaching_job_roles subjects ect_statuses],
              support_job_roles: %w[teaching_assistant],
            ))
      .and_return(search)
  end

  describe ".exists?" do
    it "returns whether a landing page has been set up" do
      expect(described_class.exists?("full-time-school-jobs")).to be(true)
      expect(described_class.exists?("i-do-not-exist")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a configured landing page instance if a landing page with the given slug exists" do
      expect(described_class["teaching-assistant-jobs-v2"].slug)
        .to eq("teaching-assistant-jobs-v2")
      expect(described_class["teaching-assistant-jobs-v2"].criteria).to eq(
        {
          hidden_filters: %w[visa_sponsorship teaching_job_roles subjects ect_statuses],
          support_job_roles: %w[teaching_assistant],
          banner_image: "landing_pages/teaching_support_banner.jpg",
        },
      )
    end

    it "raises an error if no landing page with the given slug has been configured" do
      expect { described_class["i-do-not-exist"] }
        .to raise_error("No such landing page: 'i-do-not-exist'")
    end
  end

  describe ".matching" do
    it "returns the first landing page exactly matching the given criteria, or nil if none matches" do
      expect(
        described_class
          .matching(
            hidden_filters: %w[visa_sponsorship teaching_job_roles subjects ect_statuses],
            support_job_roles: %w[teaching_assistant],
            banner_image: "landing_pages/teaching_support_banner.jpg",
          )
          .slug,
      ).to eq("teaching-assistant-jobs-v2")

      # Do not find based on partially matching criteria:
      expect(described_class.matching(subjects: %w[Potions Sorcery])).to be_nil

      expect(described_class.matching(foo: %w[bar])).to be_nil
    end
  end

  describe ".partially_matching" do
    it "returns the first landing page partially matching the given criteria, or nil if none matches" do
      expect(
        described_class
          .partially_matching(subjects: ["Religious education"])
          .slug,
      ).to eq("psychology-philosophy-sociology-re-teacher-jobs")

      # Do not find based on partially matching criteria:
      expect(described_class.partially_matching(subjects: %w[Potions Sorcery])).to be_nil

      expect(described_class.partially_matching(foo: %w[bar])).to be_nil
    end
  end

  describe "#count" do
    it "performs a search and returns its total count" do
      expect(landing_page.count).to eq(42)
    end
  end

  describe "i18n methods" do
    specify { expect(landing_page.heading).to eq("<span class=\"govuk-!-font-weight-bold\">42</span> teaching assistant jobs") }
    specify { expect(landing_page.meta_description).to eq("Find full and part time teaching assistant jobs and classroom assistant vacancies. See which schools near you are currently hiring TAs and LSAs.") }
    specify { expect(landing_page.name).to eq("Teaching assistant") }
    specify { expect(landing_page.title).to eq("Teaching Assistant Jobs") }
    specify { expect(landing_page.banner_title).to eq("Find your teaching assistant job") }
  end

  describe "has_banner_image?" do
    it "returns true if the landing page has a banner image" do
      expect(landing_page.has_banner_image?).to be(true)
    end
  end
end
