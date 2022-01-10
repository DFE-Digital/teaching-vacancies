require "rails_helper"

RSpec.describe Subscription do
  it { is_expected.to have_many(:alert_runs) }
  it { is_expected.to respond_to(:recaptcha_score) }

  context "before_create" do
    let!(:subscription) { create(:subscription, email: "john@lennon.con") }

    context "when creating a subscription with email ending in `.con`" do
      it "saves it with email ending in `.com`" do
        expect(subscription.email).to eq "john@lennon.com"
      end
    end
  end

  describe "scopes" do
    before(:each) do
      create_list(:subscription, 3, frequency: :daily)
      create_list(:subscription, 5, frequency: :weekly)
      create(:subscription, frequency: :daily, active: false)
    end

    describe "#daily" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.daily.count).to eq(4)
      end
    end

    describe "#weekly" do
      it "retrieves all subscriptions with frequency set to :daily" do
        expect(Subscription.weekly.count).to eq(5)
      end
    end

    describe "active" do
      it "retrieves all subscriptions with active set to true" do
        expect(Subscription.active.count).to eq(8)
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
          token_values = { id: subscription.id, expires: }
          Subscription.encryptor.encrypt_and_sign(token_values)
        end

        it "finds by token" do
          expect(result).to eq(subscription)
        end
      end
    end
  end

  context "vacancies_for_range" do
    let!(:expired_now) { Time.current }
    let(:date_yesterday) { Time.zone.yesterday.to_time }
    let(:date_today) { Date.current.to_time }
    let(:subscription) { create(:subscription, frequency: :daily, search_criteria: { keyword: "english" }) }
    let(:vacancies) { double("vacancies") }
    let(:vacancy_search) { double(vacancies:) }

    it "searches with an appropriate date range" do
      expect(Search::VacancySearch).to receive(:new).with(
        {
          keyword: "english",
          from_date: date_yesterday,
          to_date: date_today,
        },
        { per_page: 500 },
      ).and_return(vacancy_search)

      travel_to(expired_now) do
        expect(subscription.vacancies_for_range(date_yesterday, date_today)).to eq(vacancies)
      end
    end
  end

  describe "alert_run_today?" do
    let(:subscription) { create(:subscription, frequency: :daily) }
    subject { subscription.alert_run_today? }

    context "when an alert has run today" do
      before do
        subscription.alert_runs.find_or_create_by(run_on: Date.current)
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
      expect(subscription.alert_runs.first.run_on).to eq(Date.current)
    end

    context "if a run exists for today" do
      let!(:alert_run) { subscription.alert_runs.create(run_on: Date.current) }

      it "does not create another run" do
        subscription.create_alert_run

        expect(subscription.alert_runs.count).to eq(1)
        expect(subscription.alert_runs.first.id).to eq(alert_run.id)
      end
    end
  end
end
