require 'feature_flag'

FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']

EmailAlertsFeature = FeatureFlag.new('email_alerts')
