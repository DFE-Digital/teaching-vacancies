require 'feature_flag'

FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']

EmailAlertsFeature = FeatureFlag.new('email_alerts')
ImportVacanciesFeature = FeatureFlag.new('import_vacancies')
