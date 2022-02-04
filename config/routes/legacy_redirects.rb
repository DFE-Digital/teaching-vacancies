# These routes/paths used to exist and now have moved or no longer exist. Users may still have them
# bookmarked, so redirect them to their new equivalent or somewhere else sensible.

# Legacy authentication paths
get "/identifications/new", to: redirect("/publishers/sign-in")
get "/publishers/sign_in", to: redirect("/publishers/sign-in")
get "/publishers/sign_out", to: redirect("/publishers/sign-out")
get "/publishers/account_requests/new", to: redirect("/publishers/account-requests/new")
get "/jobseekers/sign_in", to: redirect("/jobseekers/sign-in")

# NQT is now called ECT
get "teaching-jobs-for-nqt-suitable", to: redirect("ect-suitable-jobs")
get "teaching-jobs-for-nqt_suitable", to: redirect("ect-suitable-jobs")
get "sign-up-for-NQT-job-alerts", to: redirect("/sign-up-for-ECT-job-alerts")

# Legacy landing pages
## Job roles
get "teaching-jobs-for-teacher", to: redirect("teacher-jobs")
get "teaching-jobs-for-leadership", to: redirect("leadership-jobs")
get "teaching-jobs-for-teaching_assistant", to: redirect("teaching-assistant-jobs")
get "teaching-jobs-for-teaching-assistant", to: redirect("teaching-assistant-jobs")
get "teaching-jobs-for-education_support", to: redirect("education-support-jobs")
get "teaching-jobs-for-education-support", to: redirect("education-support-jobs")
get "teaching-jobs-for-sendco", to: redirect("sendco-jobs")
get "teaching-jobs-for-send_responsible", to: redirect("send-responsible-jobs")
get "teaching-jobs-for-send-responsible", to: redirect("send-responsible-jobs")
get "teaching-jobs-for-ect_suitable", to: redirect("ect-suitable-jobs")
get "teaching-jobs-for-ect-suitable", to: redirect("ect-suitable-jobs")
