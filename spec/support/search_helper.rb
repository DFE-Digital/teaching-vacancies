module SearchHelper
  def mock_algolia_search(result, query, algolia_hash = {})
    arguments_to_algolia = {
      aroundLatLng: algolia_hash[:aroundLatLng] || nil,
      aroundRadius: algolia_hash[:aroundRadius] || nil,
      replica: algolia_hash[:replica] || nil,
      hitsPerPage: algolia_hash[:hitsPerPage] || 10,
      filters: algolia_hash[:filters] ||
        "publication_date <= #{Time.zone.today.to_datetime.to_i} AND expiry_time > #{Time.zone.today.to_datetime.to_i}"
    }
    arguments_to_algolia[:page] = algolia_hash[:page] if algolia_hash[:page].present?

    allow(Vacancy).to receive(:search).with(
      query,
      arguments_to_algolia
    ).and_return(result)
  end
end
