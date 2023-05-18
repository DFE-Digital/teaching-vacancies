require "rails_helper"

RSpec.describe Publishers::VacancyStats do
  subject { described_class.new(vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, publish_on: Date.new(1999, 12, 31)) }
  let(:big_query) { double("BigQuery") }

  before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(big_query)
    allow(vacancy).to receive(:id).and_return("id")
  end

  describe "#number_of_unique_views" do
    let(:response) { [{ number_of_unique_vacancy_views: 42 }] }
    let(:expected_sql) do
      <<~SQL
        SELECT number_of_unique_vacancy_views
        FROM `test_dataset.vacancies_published`
        WHERE id="id"
        AND publish_on = "1999-12-31"
      SQL
    end

    context "when data is available from BigQuery" do
      before { allow(big_query).to receive(:query).with(expected_sql).and_return(response) }

      it "retrieves the vacancy view count from the BigQuery API" do
        expect(subject.number_of_unique_views).to eq(42)
      end
    end

    context "when no data is available from BigQuery" do
      before { allow(big_query).to receive(:query).with(expected_sql).and_return([]) }

      it "returns 0" do
        expect(subject.number_of_unique_views).to eq(0)
      end
    end
  end
end
