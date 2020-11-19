require "flag"

AUTHENTICATION_FALLBACK = ENV["AUTHENTICATION_FALLBACK"]
DISABLE_EXPENSIVE_JOBS = ENV["DISABLE_EXPENSIVE_JOBS"]

FEATURE_JOBSEEKER_ACCOUNTS = ENV["FEATURE_JOBSEEKER_ACCOUNTS"]
FEATURE_LOCAL_AUTHORITY_ACCESS = ENV["FEATURE_LOCAL_AUTHORITY_ACCESS"]
FEATURE_READ_ONLY = ENV["FEATURE_READ_ONLY"]

AuthenticationFallback = Flag.new("authentication_fallback", is_feature: false)
DisableExpensiveJobs = Flag.new("disable_expensive_jobs", is_feature: false)

JobseekerAccountsFeature = Flag.new("jobseeker_accounts")
LocalAuthorityAccessFeature = Flag.new("local_authority_access")
ReadOnlyFeature = Flag.new("read_only")
