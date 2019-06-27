require 'feature_flag'

FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']
FEATURE_DFE_SIGN_IN_AUTHORISATION = ENV['FEATURE_DFE_SIGN_IN_AUTHORISATION']

EmailAlertsFeature = FeatureFlag.new('email_alerts')
ImportVacanciesFeature = FeatureFlag.new('import_vacancies')
DfeSignInAuthorisationFeature = FeatureFlag.new('dfe_sign_in_authorisation')
