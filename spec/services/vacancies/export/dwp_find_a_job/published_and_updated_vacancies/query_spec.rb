require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::PublishedAndUpdated::Query do
  let(:vacancy) { build_stubbed(:vacancy, :published) }

  subject { described_class.new("2024-05-01") }

  before do
    travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
  end

  after do
    travel_back
  end

  describe "#vacancies" do
    let(:school) { create(:school) }
    let(:published_internal_vacancy) { create(:vacancy, :published, publish_on: "2024-05-02", expires_at: "2024-05-12", created_at: 1.week.ago, updated_at: 1.week.ago) }
    let(:published_internal_before_date_vacancy) { create(:vacancy, :published, publish_on: "2024-04-30", expires_at: "2024-05-12", created_at: 1.week.ago, updated_at: 1.week.ago) }
    let(:published_internal_updated_vacancy) { create(:vacancy, :published, publish_on: "2024-04-30", expires_at: "2024-05-12", created_at: 1.week.ago, updated_at: Time.zone.now) }
    let(:unpublished_internal_vacancy) { create(:vacancy, :published, publish_on: "2024-05-03", expires_at: "2024-05-12", created_at: 1.week.ago, updated_at: 1.week.ago) }
    let(:publised_external_vacancy) do
      build(:vacancy, :published, :external, publish_on: "2024-05-02", expires_at: "2024-05-12", organisations: [school], created_at: 1.week.ago, updated_at: 1.week.ago).tap do |v|
        v.save(validate: false)
      end
    end

    it "includes internal vacancies already published after the from_date" do
      published_internal_vacancy
      expect(subject.vacancies).to contain_exactly(published_internal_vacancy)
    end

    it "does not include interal vacancies published before the from_date" do
      published_internal_before_date_vacancy
      expect(subject.vacancies).to be_empty
    end

    it "includes interal vacancies published before the from_date but updated after the from_date" do
      published_internal_updated_vacancy
      expect(subject.vacancies).to contain_exactly(published_internal_updated_vacancy)
    end

    it "does not include internal vacancies still waiting to be published" do
      unpublished_internal_vacancy
      expect(subject.vacancies).to be_empty
    end

    it "does not include published vacancies from external sources" do
      publised_external_vacancy
      expect(subject.vacancies).to be_empty
    end

    describe "vacancies that need to be reposted" do
      [31, 62, 93, 124, 155, 186].each do |days|
        it "includes internal vacancies published exactly #{days} days ago" do
          vacancy = create(:vacancy, :published, publish_on: days.days.ago, expires_at: Time.zone.now + 12.days,
                                                 created_at: days.days.ago, updated_at: days.days.ago)
          expect(subject.vacancies).to contain_exactly(vacancy)
        end
      end

      [15, 30, 60, 61, 63].each do |days|
        it "does not include internal vacancies published exactly #{days} days ago" do
          create(:vacancy, :published, publish_on: days.days.ago, expires_at: Time.zone.now + 12.days,
                                       created_at: days.days.ago, updated_at: days.days.ago)
          expect(subject.vacancies).to be_empty
        end
      end
    end

    it "combines all the vacancy selection criterias" do
      create(:vacancy, :published, publish_on: 30.days.ago, expires_at: Time.zone.now + 56.days, created_at: 50.days.ago, updated_at: 50.days.ago)

      published_internal_31_days_ago_vacancy = create(:vacancy, :published, publish_on: 31.days.ago, expires_at: Time.zone.now + 56.days, created_at: 50.days.ago, updated_at: 50.days.ago)
      published_internal_62_days_ago_vacancy = create(:vacancy, :published, publish_on: 62.days.ago, expires_at: Time.zone.now + 56.days, created_at: 70.days.ago, updated_at: 70.days.ago)
      published_internal_vacancy
      published_internal_before_date_vacancy
      published_internal_updated_vacancy
      unpublished_internal_vacancy
      publised_external_vacancy

      expect(subject.vacancies).to contain_exactly(
        published_internal_vacancy,
        published_internal_updated_vacancy,
        published_internal_31_days_ago_vacancy,
        published_internal_62_days_ago_vacancy,
      )
    end
  end
end
