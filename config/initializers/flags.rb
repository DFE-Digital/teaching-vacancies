require 'flag'

AUTHENTICATION_FALLBACK = ENV['AUTHENTICATION_FALLBACK']
FEATURE_READ_ONLY = ENV['FEATURE_READ_ONLY']
FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']

AuthenticationFallback = FeatureFlag.new('authentication_fallback', is_feature: false)
ReadOnlyFeature = FeatureFlag.new('read_only')
EmailAlertsFeature = FeatureFlag.new('email_alerts')
ImportVacanciesFeature = FeatureFlag.new('import_vacancies')
