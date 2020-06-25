module SearchHelper
  DEFAULT_INDEX = "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_publish_on_desc"

  def mock_algolia_search(result, query, algolia_hash = {})
    arguments_to_algolia = {
      aroundLatLng: algolia_hash[:aroundLatLng] || nil,
      aroundRadius: algolia_hash[:aroundRadius] || nil,
      replica: algolia_hash[:replica] || DEFAULT_INDEX,
      hitsPerPage: algolia_hash[:hitsPerPage] || 10,
      filters: algolia_hash[:filters] ||
        "publication_timestamp <= #{Time.zone.today.to_datetime.to_i} AND "\
        "expires_at_timestamp > #{Time.zone.today.to_datetime.to_i}"
    }
    arguments_to_algolia[:page] = algolia_hash[:page] if algolia_hash[:page].present?

    allow(Vacancy).to receive(:search).with(
      query,
      arguments_to_algolia
    ).and_return(result)
  end
end
