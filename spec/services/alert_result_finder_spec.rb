require 'rails_helper'

RSpec.describe AlertResultFinder do
  let(:from_date) { 2.days.ago.strftime('%Y-%m-%d') }
  let(:to_date) { Time.zone.yesterday.strftime('%Y-%m-%d') }

  it 'generates ES filters from the search_criteria' do
    expect(VacancyFilters).to receive(:new).with({})
                                           .and_return(VacancyFilters.new({}))

    AlertResultFinder.new({}, from_date, to_date).call
  end

  it 'correctly retrieves the expected_results for a specified time period' do
    build_list(:vacancy, 4, :published_slugged, publish_on: 2.days.ago).each { |v| v.save(validate: false) }
    create_list(:vacancy, 2, :published_slugged)
    Vacancy.__elasticsearch__.client.indices.flush

    results = AlertResultFinder.new({}, from_date, to_date).call
    expect(results.records.count).to eq(4)
  end
end
