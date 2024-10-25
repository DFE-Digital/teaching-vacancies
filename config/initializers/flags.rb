require "flag"

AUTHENTICATION_FALLBACK = ENV.fetch("AUTHENTICATION_FALLBACK", nil)
AUTHENTICATION_FALLBACK_FOR_JOBSEEKERS = ENV.fetch("AUTHENTICATION_FALLBACK_F0R_JOBSEEKERS", nil)
DISABLE_EXPENSIVE_JOBS = ENV.fetch("DISABLE_EXPENSIVE_JOBS", nil)

AuthenticationFallback = Flag.new("authentication_fallback", is_feature: false)
AuthenticationFallbackForJobseekers = Flag.new("authentication_fallback_for_jobseekers", is_feature: false)
DisableExpensiveJobs = Flag.new("disable_expensive_jobs", is_feature: false)
