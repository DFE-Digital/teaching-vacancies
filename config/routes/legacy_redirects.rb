# These routes/paths used to exist and now have moved or no longer exist. Users may still have them
# bookmarked, so redirect them to their new equivalent or somewhere else sensible.

# Legacy authentication paths
get "/identifications/new", to: redirect("/publishers/sign-in")
get "/publishers/sign_in", to: redirect("/publishers/sign-in")
get "/publishers/sign_out", to: redirect("/publishers/sign-out")
get "/publishers/account_requests/new", to: redirect("/publishers/account-requests/new")
get "/jobseekers/sign_in", to: redirect("/jobseekers/sign-in")

# NQT is now called ECT
get "teaching-jobs-for-nqt_suitable", to: redirect("teaching-jobs-for-ect-suitable")
get "sign-up-for-NQT-job-alerts", to: redirect("/sign-up-for-ECT-job-alerts")
