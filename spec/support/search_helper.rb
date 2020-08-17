module SearchHelper
  def mock_algolia_search_for_job_alert(result, query, algolia_hash = {})
    arguments_to_algolia = get_arguments_to_algolia(algolia_hash)
    arguments_to_algolia[:typoTolerance] = false
    mock_algolia_search_base(result, query, algolia_hash, arguments_to_algolia)
  end

  def mock_algolia_search(result, query, algolia_hash = {})
    arguments_to_algolia = get_arguments_to_algolia(algolia_hash)
    mock_algolia_search_base(result, query, algolia_hash, arguments_to_algolia)
  end

  private

  def get_arguments_to_algolia(algolia_hash)
    {
      aroundLatLng: algolia_hash[:aroundLatLng] || nil,
      aroundRadius: algolia_hash[:aroundRadius] || nil,
      insidePolygon: algolia_hash[:insidePolygon] || nil,
      filters: algolia_hash[:filters] || nil,
      replica: algolia_hash[:replica] || nil,
      hitsPerPage: algolia_hash[:hitsPerPage] || 10,
    }
  end

  def mock_algolia_search_base(result, query, algolia_hash, arguments_to_algolia)
    arguments_to_algolia[:page] = algolia_hash[:page] if algolia_hash[:page].present?
    allow(Vacancy).to receive(:search).with(
      query,
      arguments_to_algolia
    ).and_return(result)
  end
end
