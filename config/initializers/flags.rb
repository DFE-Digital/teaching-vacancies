require 'flag'

AUTHENTICATION_FALLBACK = ENV['AUTHENTICATION_FALLBACK']
FEATURE_READ_ONLY = ENV['FEATURE_READ_ONLY']
FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']
FEATURE_SCHOOL_GROUP_JOBS = ENV['FEATURE_SCHOOL_GROUP_JOBS']
FEATURE_MULTI_SCHOOL_JOBS = ENV['FEATURE_MULTI_SCHOOL_JOBS']

AuthenticationFallback = Flag.new('authentication_fallback', is_feature: false)
ReadOnlyFeature = Flag.new('read_only')
EmailAlertsFeature = Flag.new('email_alerts')
ImportVacanciesFeature = Flag.new('import_vacancies')
SchoolGroupJobsFeature = Flag.new('school_group_jobs')
MultiSchoolJobsFeature = Flag.new('multi_school_jobs')
