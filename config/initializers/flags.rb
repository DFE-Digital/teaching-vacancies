require "flag"

AUTHENTICATION_FALLBACK = ENV["AUTHENTICATION_FALLBACK"]
DISABLE_EXPENSIVE_JOBS = ENV["DISABLE_EXPENSIVE_JOBS"]

FEATURE_JOBSEEKER_APPLICATIONS = ENV["FEATURE_JOBSEEKER_APPLICATIONS"]
FEATURE_LOCAL_AUTHORITY_ACCESS = ENV["FEATURE_LOCAL_AUTHORITY_ACCESS"]

AuthenticationFallback = Flag.new("authentication_fallback", is_feature: false)
DisableExpensiveJobs = Flag.new("disable_expensive_jobs", is_feature: false)

JobseekerApplicationsFeature = Flag.new("jobseeker_applications")
LocalAuthorityAccessFeature = Flag.new("local_authority_access")
