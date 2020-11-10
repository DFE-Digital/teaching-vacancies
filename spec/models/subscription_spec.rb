require "rails_helper"

RSpec.describe Subscription, type: :model do
  it { should have_many(:alert_runs) }
  it { should have_many(:job_alert_feedbacks) }
  it { should respond_to(:recaptcha_score) }

  describe "scopes" do
    before(:each) do
      create_list(:subscription, 3, frequency: :daily)
      create_list(:subscription, 5, frequency: :weekly)
      create(:subscription, frequency: :daily, active: false)
    end

    describe "#daily" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.daily.count).to eql(4)
      end
    end

    describe "#weekly" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.weekly.count).to eql(5)
      end
    end

    describe "active" do
      it "retrieves all subscriptions with active set to true" do
        expect(Subscription.active.count).to eql(8)
      end
    end
  end

  context "token generation" do
    before do
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SECRET", "foo")
      stub_const("SUBSCRIPTION_KEY_GENERATOR_SALT", "bar")
    end

    let(:subscription) { create(:subscription, frequency: :daily) }
    let(:token) { subscription.token }

    it "generates a token" do
      expect(token).to_not be_nil
    end

    describe "#find_and_verify_by_token" do
      let(:result) { Subscription.find_and_verify_by_token(token) }

      it "finds by token" do
        expect(result).to eq(subscription)
      end

      context "when token is old" do
        let(:token) { subscription.token }

        it "finds by token" do
          travel 3.days do
            expect(result).to eq(subscription)
          end
        end
      end

      context "when token is incorrect" do
        let(:token) { subscription.id }

        it "raises an error" do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when token has extra data" do
        let(:token) do
          expires = Time.current + 2.days
          token_values = { id: subscription.id, expires: expires }
          Subscription.encryptor.encrypt_and_sign(token_values)
        end

        it "finds by token" do
          expect(result).to eq(subscription)
        end
      end
    end
  end

  context "vacancies_for_range" do
    let!(:expired_now) { Time.zone.now }
    let(:date_yesterday) { Time.zone.yesterday.to_time }
    let(:date_today) { Time.zone.today.to_time }
    let(:subscription) { create(:subscription, frequency: :daily, search_criteria: { keyword: "english" }.to_json) }
    let(:vacancies) { double("vacancies") }
    let(:search_filter) do
      "(publication_date_timestamp <= #{date_today.to_i} AND expires_at_timestamp > "\
      "#{expired_now.to_time.to_i}) AND (publication_date_timestamp >= #{date_yesterday.to_i}"\
      " AND publication_date_timestamp <= #{date_today.to_i})"
    end

    let(:algolia_search_query) { "english" }
    let(:algolia_search_args) do
      {
        filters: search_filter,
        hitsPerPage: Search::VacancyAlertBuilder::MAXIMUM_SUBSCRIPTION_RESULTS,
      }
    end

    before do
      travel_to expired_now
      allow_any_instance_of(Search::VacancyFiltersBuilder)
        .to receive(:expired_now_filter)
        .and_return(expired_now.to_time.to_i)
      allow(vacancies).to receive(:count).and_return(10)
      mock_algolia_search_for_job_alert(vacancies, algolia_search_query, algolia_search_args)
    end

    after { travel_back }

    it "calls out to algolia search" do
      expect(subscription.vacancies_for_range(date_yesterday, date_today)).to eql(vacancies)
    end
  end

  describe "alert_run_today?" do
    let(:subscription) { create(:subscription, frequency: :daily) }
    subject { subscription.alert_run_today? }

    context "when an alert has run today" do
      before do
        subscription.alert_runs.find_or_create_by(run_on: Time.zone.today)
      end

      it { expect(subject).to eq(true) }
    end

    context "when an alert ran yesterday" do
      before do
        subscription.alert_runs.find_or_create_by(run_on: Time.zone.yesterday)
      end

      it { expect(subject).to eq(false) }
    end

    context "when an alert has never run" do
      it { expect(subject).to eq(false) }
    end
  end

  describe "create_alert_run" do
    let(:subscription) { create(:subscription, frequency: :daily) }

    it "creates a run" do
      subscription.create_alert_run

      expect(subscription.alert_runs.count).to eq(1)
      expect(subscription.alert_runs.first.run_on).to eq(Time.zone.today)
    end

    context "if a run exists for today" do
      let!(:alert_run) { subscription.alert_runs.create(run_on: Time.zone.today) }

      it "does not create another run" do
        subscription.create_alert_run

        expect(subscription.alert_runs.count).to eq(1)
        expect(subscription.alert_runs.first.id).to eq(alert_run.id)
      end
    end
  end
end
