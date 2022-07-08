json.info do
  json.title "GOV UK - #{t('app.title')}"
  json.description t("app.description")
  json.termsOfService page_url("terms-and-conditions", anchor: "terms-and-conditions-for-api-users")
  json.contact do
    json.name "#{t('app.title')} API Support"
    json.email t("help.email")
  end
  json.license do
    json.name "Open Government License"
    json.url "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"
  end
  json.version "0.1.0"
end
json.openapi "3.0.0"

json.data @vacancies.each do |vacancy|
  json.partial! "show", vacancy: VacancyPresenter.new(vacancy)
end

json.links do
  json.self  api_jobs_url(page: @pagy.page, format: :json)
  json.first api_jobs_url(page: 1, format: :json)
  json.last  api_jobs_url(page: @pagy.last, format: :json)
  json.prev((api_jobs_url(page: @pagy.prev, format: :json) if @pagy.prev))
  json.next((api_jobs_url(page: @pagy.next, format: :json) if @pagy.next))
end

json.meta do
  json.totalPages @pagy.pages
end
