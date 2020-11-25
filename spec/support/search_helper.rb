module SearchHelper
  def mock_algolia_search(result, count, query, arguments_to_algolia)
    allow(result).to receive(:raw_answer).and_return({ "page" => 1, "nbPages" => 1, "hitsPerPage" => 10, "nbHits" => count })
    allow(Vacancy).to receive(:search).with(query, arguments_to_algolia).and_return(result)
  end
end
