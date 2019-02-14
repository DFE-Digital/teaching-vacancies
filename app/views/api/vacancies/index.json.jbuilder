json.info do
  json.title "GOV UK - #{I18n.t('app.title')}"
  json.description I18n.t('app.description')
  json.termsOfService terms_and_conditions_url(protocol: 'https', anchor: 'api')
  json.contact do
    json.name "#{I18n.t('app.title')} API Support"
    json.email I18n.t('help.email')
  end
  json.license do
    json.name 'Open Government License'
    json.url 'https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/'
  end
  json.version '0.1.0'
end
json.openapi '3.0.0'

json.data @vacancies.decorated_collection do |vacancy|
  json.partial! 'show.json.jbuilder', vacancy: vacancy
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
