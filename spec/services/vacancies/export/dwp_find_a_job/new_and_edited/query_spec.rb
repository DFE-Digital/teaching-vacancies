require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::NewAndEdited::Query do
  subject { described_class.new("2024-05-01") }

  let(:vacancy) { build_stubbed(:vacancy, :published) }

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
    let(:published_internal_reached_max_expiry_threshold) do
      create(:vacancy, :published, publish_on: "2024-04-30", expires_at: Time.zone.now + 30.days, created_at: 1.week.ago, updated_at: 1.week.ago)
    end
    let(:published_internal_vacancy_over_max_expiry_threshold) do
      create(:vacancy, :published, publish_on: "2024-04-30", expires_at: Time.zone.now + 31.days, created_at: 1.week.ago, updated_at: 1.week.ago)
    end
    let(:published_internal_vacancy_with_expiration_exactly_12_weeks_from_today) do
      create(:vacancy, :published, publish_on: "2024-04-30", expires_at: Time.zone.now + 12.weeks, created_at: 1.week.ago, updated_at: 1.week.ago)
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

    it "includes internal vacancies published before the form_date, not updated since, but now have 30 days to expire" do
      published_internal_reached_max_expiry_threshold
      expect(subject.vacancies).to contain_exactly(published_internal_reached_max_expiry_threshold)
    end

    describe "vacancies over 30 days inclusion" do
      it "are not included if the expiration date is not 7*x days (exactly 'x' weeks) away from today" do
        published_internal_vacancy_over_max_expiry_threshold
        expect(subject.vacancies).to be_empty
      end

      it "are included if the expiration date is 7*x days (exactly 'x' weeks) away from today" do
        published_internal_vacancy_with_expiration_exactly_12_weeks_from_today
        expect(subject.vacancies)
          .to contain_exactly(published_internal_vacancy_with_expiration_exactly_12_weeks_from_today)
      end
    end

    it "combines all the vacancy selection criterias" do
      published_internal_vacancy
      published_internal_before_date_vacancy
      published_internal_updated_vacancy
      unpublished_internal_vacancy
      publised_external_vacancy
      published_internal_reached_max_expiry_threshold
      published_internal_vacancy_over_max_expiry_threshold
      published_internal_vacancy_with_expiration_exactly_12_weeks_from_today

      expect(subject.vacancies).to contain_exactly(
        published_internal_vacancy,
        published_internal_updated_vacancy,
        published_internal_reached_max_expiry_threshold,
        published_internal_vacancy_with_expiration_exactly_12_weeks_from_today,
      )
    end
  end
end
