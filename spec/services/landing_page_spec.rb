require "rails_helper"

# This spec relies on a fake landing page set up in the test section of `config/landing_pages.yml`
# and the translation file.
RSpec.describe LandingPage do
  subject { described_class["part-time-potions-and-sorcery-teacher-jobs"] }

  let(:search) { instance_double(Search::VacancySearch, total_count: 42) }

  before do
    allow(Search::VacancySearch)
      .to receive(:new)
      .with(hash_including(working_patterns: %w[part_time], subjects: %w[Potions Sorcery]))
      .and_return(search)
  end

  describe ".exists?" do
    it "returns whether a landing page has been set up" do
      expect(described_class.exists?("part-time-potions-and-sorcery-teacher-jobs")).to be(true)
      expect(described_class.exists?("i-do-not-exist")).to be(false)
    end
  end

  describe ".[]" do
    it "returns a configured landing page instance if a landing page with the given slug exists" do
      expect(described_class["part-time-potions-and-sorcery-teacher-jobs"].slug)
        .to eq("part-time-potions-and-sorcery-teacher-jobs")
      expect(described_class["part-time-potions-and-sorcery-teacher-jobs"].criteria)
        .to eq({ working_patterns: %w[part_time], subjects: %w[Potions Sorcery] })
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
          .matching(working_patterns: %w[part_time], subjects: %w[Potions Sorcery])
          .slug,
      ).to eq("part-time-potions-and-sorcery-teacher-jobs")

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
      expect(subject.count).to eq(42)
    end
  end

  describe "i18n methods" do
    specify { expect(subject.heading).to eq("<span class=\"govuk-!-font-weight-bold\">42</span> amazing jobs APPLY NOW") }
    specify { expect(subject.meta_description).to eq("Lorem ipsum dolor sit jobs, vacancies adipiscing elit.") }
    specify { expect(subject.name).to eq("Potions and Sorcery") }
    specify { expect(subject.title).to eq("Spiffy Part Time Potions and Sorcery Jobs") }
  end
end
