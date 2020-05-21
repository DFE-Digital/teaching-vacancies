require 'feature_flag'

FEATURE_READ_ONLY = ENV['FEATURE_READ_ONLY']
FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_EMAIL_SIGN_IN = ENV['FEATURE_EMAIL_SIGN_IN']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']


ReadOnlyFeature = FeatureFlag.new('read_only')
EmailAlertsFeature = FeatureFlag.new('email_alerts')
EmailSignInFeature = FeatureFlag.new('email_sign_in')
ImportVacanciesFeature = FeatureFlag.new('import_vacancies')
