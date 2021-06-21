AlgoliaSearch.configuration = {
  application_id: Rails.env.test? ? "Placeholder" : ENV.fetch("ALGOLIA_APP_ID", "Placeholder"),
  api_key: Rails.env.test? ? "Placeholder" : ENV.fetch("ALGOLIA_WRITE_API_KEY", "Placeholder"),
  pagination_backend: :kaminari,
}

# Fix for Ruby 3.0+
# The original relies on kwargs munging behaviour that is no longer possible in Ruby 3.
# We'd fix this upstream but we plan to migrate away from Algolia soon anyway so this
# monkey-patches it instead.
# c.f. https://github.com/algolia/algoliasearch-rails/blob/master/lib/algoliasearch/pagination/kaminari.rb#L12
class AlgoliaSearch::Pagination::Kaminari < ::Kaminari::PaginatableArray
  def initialize(array, options)
    super(array, **options)
  end
end
