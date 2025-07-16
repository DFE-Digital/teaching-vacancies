require "flag"

AUTHENTICATION_FALLBACK = ENV.fetch("AUTHENTICATION_FALLBACK", nil)
AUTHENTICATION_FALLBACK_FOR_JOBSEEKERS = ENV.fetch("AUTHENTICATION_FALLBACK_FOR_JOBSEEKERS", nil)
DISABLE_EMAIL_NOTIFICATIONS = ENV.fetch("DISABLE_EMAIL_NOTIFICATIONS", nil)
DISABLE_EXPENSIVE_JOBS = ENV.fetch("DISABLE_EXPENSIVE_JOBS", nil)
DISABLE_INTEGRATIONS = ENV.fetch("DISABLE_INTEGRATIONS", nil)

AuthenticationFallback = Flag.new("authentication_fallback", is_feature: false)
AuthenticationFallbackForJobseekers = Flag.new("authentication_fallback_for_jobseekers", is_feature: false)

# Avoid sending subscription alerts, expired vacancy feedback prompts, and other email notifications
DisableEmailNotifications = Flag.new("disable_email_notifications", is_feature: false)

# Avoid executing any job flagged as expensive.
DisableExpensiveJobs = Flag.new("disable_expensive_jobs", is_feature: false)

# Avoid executing any job that integrates with external systems, such as Google Index updates, ATS imports, etc.
DisableIntegrations = Flag.new("disable_integrations", is_feature: false)
