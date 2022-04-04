class Search::KeywordFilterGeneration::QueryTransformer < Parslet::Transform
  rule(filterable_term: simple(:term)) do |captures|
    term = captures[:term].to_s
    Rails.application.config.x.search.keyword_filter_mappings[term]
  end

  def self.apply(parsed_query)
    # Only transform query if query contains any matches
    return nil unless parsed_query[:query].is_a?(Array)

    new
      .apply(parsed_query)[:query]
      .each_with_object(Hash.new([])) do |item, acc|
        item.each { |k, v| acc[k] |= v }
      end
  end
end
