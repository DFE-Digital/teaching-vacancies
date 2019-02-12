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
  json.version '0.0.1'
end
json.openapi '3.0.0'

json.data @vacancies.decorated_collection do |vacancy|
  json.partial! 'show.json.jbuilder', vacancy: vacancy
end

json.links do
  json.self  api_jobs_url(page: @vacancies.current_page)
  json.first api_jobs_url
  json.last  api_jobs_url(page: @vacancies.total_pages)
  json.prev  url_to_prev_page(@vacancies)
  json.next  url_to_next_page(@vacancies)
end
