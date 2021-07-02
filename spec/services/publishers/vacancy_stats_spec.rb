require "rails_helper"

RSpec.describe Publishers::VacancyStats do
  subject { described_class.new(vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, id: "decaf-baaad") }
  let(:big_query) { double("BigQuery") }

  before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(big_query)
  end

  describe "#number_of_unique_views" do
    let(:response) { [{ number_of_unique_vacancy_views: 42 }] }

    before do
      allow(big_query).to receive(:query)
        .with(/SELECT number_of_unique_vacancy_views.*WHERE id="#{StringAnonymiser.new(vacancy.id)}"/m)
        .and_return(response)
    end

    it "retrieves the vacancy view count from the BigQuery API" do
      expect(subject.number_of_unique_views).to eq(42)
    end
  end
end
