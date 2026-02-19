require "rails_helper"

RSpec.describe VacancyConflictAttempt do
  describe "associations" do
    it { is_expected.to belong_to(:publisher_ats_api_client) }
    it { is_expected.to belong_to(:conflicting_vacancy).class_name("Vacancy") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:attempts_count) }
    it { is_expected.to validate_numericality_of(:attempts_count).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:first_attempted_at) }
    it { is_expected.to validate_presence_of(:last_attempted_at) }
  end

  describe ".track_attempt!" do
    let(:api_client) { create(:publisher_ats_api_client) }
    let(:vacancy) { create(:vacancy) }

    context "when creating a new conflict attempt" do
      it "creates a new record with correct attributes" do
        expect {
          described_class.track_attempt!(
            publisher_ats_api_client: api_client,
            conflicting_vacancy: vacancy,
          )
        }.to change(described_class, :count).by(1)

        conflict_attempt = described_class.last
        expect(conflict_attempt.publisher_ats_api_client).to eq(api_client)
        expect(conflict_attempt.conflicting_vacancy).to eq(vacancy)
        expect(conflict_attempt.attempts_count).to eq(1)
        expect(conflict_attempt.first_attempted_at).to be_within(1.minute).of(Time.current)
        expect(conflict_attempt.last_attempted_at).to be_within(1.minute).of(Time.current)
      end
    end

    context "when updating an existing conflict attempt" do
      let!(:existing_attempt) do
        described_class.create!(
          publisher_ats_api_client: api_client,
          conflicting_vacancy: vacancy,
          attempts_count: 1,
          first_attempted_at: 1.day.ago,
          last_attempted_at: 1.day.ago,
        )
      end

      it "increments the attempts_count and updates last_attempted_at" do
        expect {
          described_class.track_attempt!(
            publisher_ats_api_client: api_client,
            conflicting_vacancy: vacancy,
          )
        }.not_to change(described_class, :count)

        existing_attempt.reload
        expect(existing_attempt.attempts_count).to eq(2)
        expect(existing_attempt.last_attempted_at).to be_within(1.minute).of(Time.current)
      end
    end
  end

  describe "#conflicting_vacancy_publisher_type" do
    let(:conflict_attempt) { build(:vacancy_conflict_attempt) }

    context "when conflicting vacancy is from an API client" do
      before do
        conflict_attempt.conflicting_vacancy.publisher_ats_api_client = create(:publisher_ats_api_client)
      end

      it "returns 'api_client'" do
        expect(conflict_attempt.conflicting_vacancy_publisher_type).to eq("api_client")
      end
    end

    context "when conflicting vacancy is manually created" do
      before do
        conflict_attempt.conflicting_vacancy.publisher_ats_api_client = nil
      end

      it "returns 'manual'" do
        expect(conflict_attempt.conflicting_vacancy_publisher_type).to eq("manual")
      end
    end
  end

  describe "#conflicting_vacancy_publisher_name" do
    let(:conflict_attempt) { build(:vacancy_conflict_attempt) }

    context "when conflicting vacancy is from an API client" do
      let(:api_client) { create(:publisher_ats_api_client, name: "Test ATS") }

      before do
        conflict_attempt.conflicting_vacancy.publisher_ats_api_client = api_client
      end

      it "returns the API client name" do
        expect(conflict_attempt.conflicting_vacancy_publisher_name).to eq("Test ATS")
      end
    end

    context "when conflicting vacancy is manually created" do
      let(:organisation) { create(:school, name: "Test School") }

      before do
        conflict_attempt.conflicting_vacancy.publisher_ats_api_client = nil
        conflict_attempt.conflicting_vacancy.organisations = [organisation]
      end

      it "returns the organisation name" do
        expect(conflict_attempt.conflicting_vacancy_publisher_name).to eq("Test School")
      end
    end
  end

  describe "scopes" do
    describe ".ordered_by_latest" do
      let(:api_client) { create(:publisher_ats_api_client) }
      let(:vacancy) { create(:vacancy) }

      let!(:old_attempt) do
        create(:vacancy_conflict_attempt,
               publisher_ats_api_client: api_client,
               conflicting_vacancy: vacancy,
               last_attempted_at: 2.days.ago)
      end

      let!(:new_attempt) do
        create(:vacancy_conflict_attempt,
               publisher_ats_api_client: api_client,
               last_attempted_at: 1.day.ago)
      end

      it "orders by last_attempted_at descending" do
        expect(described_class.ordered_by_latest).to eq([new_attempt, old_attempt])
      end
    end

    describe ".for_client" do
      let(:target_api_client) { create(:publisher_ats_api_client) }
      let(:other_api_client) { create(:publisher_ats_api_client) }

      let!(:target_attempt) { create(:vacancy_conflict_attempt, publisher_ats_api_client: target_api_client) }
      let!(:other_attempt) { create(:vacancy_conflict_attempt, publisher_ats_api_client: other_api_client) }

      it "returns only attempts for the specified client" do
        expect(described_class.for_client(target_api_client.id)).to eq([target_attempt])
        expect(described_class.for_client(target_api_client.id)).not_to include(other_attempt)
      end
    end
  end
end
