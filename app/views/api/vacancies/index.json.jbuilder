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

json.data @vacancies.decorated_collection do |vacancy|
  json.partial! "show", vacancy:
end

json.links do
  json.self  @vacancies.current_api_url
  json.first @vacancies.first_api_url
  json.last  @vacancies.last_api_url
  json.prev  @vacancies.previous_api_url
  json.next  @vacancies.next_api_url
end

json.meta do
  json.totalPages @vacancies.total_pages
end
