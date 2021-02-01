AlgoliaSearch.configuration = {
  application_id: ENV.fetch("ALGOLIA_APP_ID", "Placeholder"),
  api_key: ENV.fetch("ALGOLIA_WRITE_API_KEY", "Placeholder"),
  pagination_backend: :kaminari,
}
