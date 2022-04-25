require "flag"

AUTHENTICATION_FALLBACK = ENV.fetch("AUTHENTICATION_FALLBACK", nil)
DISABLE_EXPENSIVE_JOBS = ENV.fetch("DISABLE_EXPENSIVE_JOBS", nil)

AuthenticationFallback = Flag.new("authentication_fallback", is_feature: false)
DisableExpensiveJobs = Flag.new("disable_expensive_jobs", is_feature: false)
