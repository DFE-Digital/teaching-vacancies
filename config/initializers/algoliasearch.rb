AlgoliaSearch.configuration = {
  application_id: Rails.env.test? ? "Placeholder" : ENV.fetch("ALGOLIA_APP_ID", "Placeholder"),
  api_key: Rails.env.test? ? "Placeholder" : ENV.fetch("ALGOLIA_WRITE_API_KEY", "Placeholder"),
  pagination_backend: :kaminari,
}
