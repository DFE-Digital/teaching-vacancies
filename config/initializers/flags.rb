require 'flag'

AUTHENTICATION_FALLBACK = ENV['AUTHENTICATION_FALLBACK']
DISABLE_EXPENSIVE_JOBS = ENV['DISABLE_EXPENSIVE_JOBS']

FEATURE_COOKIES_BANNER = ENV['FEATURE_COOKIES_BANNER']
FEATURE_EMAIL_ALERTS = ENV['FEATURE_EMAIL_ALERTS']
FEATURE_IMPORT_VACANCIES = ENV['FEATURE_IMPORT_VACANCIES']
FEATURE_MULTI_SCHOOL_JOBS = ENV['FEATURE_MULTI_SCHOOL_JOBS']
FEATURE_READ_ONLY = ENV['FEATURE_READ_ONLY']
FEATURE_SCHOOL_GROUP_JOBS = ENV['FEATURE_SCHOOL_GROUP_JOBS']

AuthenticationFallback = Flag.new('authentication_fallback', is_feature: false)
DisableExpensiveJobs = Flag.new('disable_expensive_jobs', is_feature: false)

CookiesBannerFeature = Flag.new('cookies_banner')
EmailAlertsFeature = Flag.new('email_alerts')
ImportVacanciesFeature = Flag.new('import_vacancies')
MultiSchoolJobsFeature = Flag.new('multi_school_jobs')
ReadOnlyFeature = Flag.new('read_only')
SchoolGroupJobsFeature = Flag.new('school_group_jobs')
