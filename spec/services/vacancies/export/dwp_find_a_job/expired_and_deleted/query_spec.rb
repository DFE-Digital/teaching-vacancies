require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ExpiredAndDeleted::Query do
  subject { described_class.new("2024-05-01") }

  let(:vacancy) { build_stubbed(:vacancy, :published) }

  before do
    travel_to(Time.zone.local(2024, 5, 3, 0, 4, 44))
  end

  after do
    travel_back
  end

  describe "#vacancies" do
    let(:school) { create(:school) }
    let(:early_ended_internal_vacancy) { create(:vacancy, expires_at: "2024-05-2T10:00:00", updated_at: "2024-05-2T10:00:00", created_at: 1.week.ago) }
    let(:early_ended_internal_before_date_vacancy) { create(:vacancy, expires_at: "2024-04-30T10:00:00", updated_at: "2024-04-30T10:00:01", created_at: 1.week.ago) }
    let(:expired_not_early_ended_internal_vacancy) { create(:vacancy, expires_at: "2024-05-2T10:00:00", created_at: 1.week.ago, updated_at: 6.days.ago) }
    let(:early_ended_external_vacancy) do
      build(:vacancy, :published, :external, publish_on: "2024-05-01", expires_at: "2024-05-2T10:00:00", updated_at: "2024-05-2T10:00:00", organisations: [school], created_at: 1.week.ago).tap do |v|
        v.save(validate: false)
      end
    end

    it "includes internal vacancies 'early ended' after from_date" do
      early_ended_internal_vacancy
      expect(subject.vacancies).to contain_exactly(early_ended_internal_vacancy)
    end

    it "does not include internal vacancies 'early ended' before from_date" do
      early_ended_internal_before_date_vacancy
      expect(subject.vacancies).to be_empty
    end

    it "does not include internal vacancies naturally expired after from_date" do
      expired_not_early_ended_internal_vacancy
      expect(subject.vacancies).to be_empty
    end

    it "does not include external vacancies 'early ended' after from_date" do
      early_ended_external_vacancy
      expect(subject.vacancies).to be_empty
    end
  end
end
