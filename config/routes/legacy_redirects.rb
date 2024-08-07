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
get "teaching-jobs-for-leadership", to: redirect("headteacher-jobs")
get "leadership-jobs", to: redirect("headteacher-jobs")
get "teaching-jobs-for-teaching_assistant", to: redirect("teaching-assistant-jobs")
get "teaching-jobs-for-teaching-assistant", to: redirect("teaching-assistant-jobs")
get "teaching-jobs-for-education_support", to: redirect("education-support-jobs")
get "teaching-jobs-for-education-support", to: redirect("education-support-jobs")
get "teaching-jobs-for-sendco", to: redirect("sendco-jobs")
get "teaching-jobs-for-ect_suitable", to: redirect("ect-suitable-jobs")
get "teaching-jobs-for-ect-suitable", to: redirect("ect-suitable-jobs")

## Education phases
get "teaching-jobs-for-primary", to: redirect("primary-school-jobs")
get "teaching-jobs-for-middle", to: redirect("middle-school-jobs")
get "teaching-jobs-for-secondary", to: redirect("secondary-school-jobs")
get "teaching-jobs-for-16-19", to: redirect("sixth-form-or-college-jobs")
get "16-19-education-provider-jobs", to: redirect("sixth-form-or-college-jobs")

## Subjects
get "teaching-jobs-for-accounting", to: redirect("economics-business-studies-teacher-jobs")
get "teaching-jobs-for-art-and-design", to: redirect("art-design-teacher-jobs")
get "teaching-jobs-for-biology", to: redirect("biology-teacher-jobs")
get "teaching-jobs-for-business-studies", to: redirect("economics-business-studies-teacher-jobs")
get "teaching-jobs-for-chemistry", to: redirect("chemistry-teacher-jobs")
get "teaching-jobs-for-citizenship", to: redirect("politics-humanities-social-sciences-teacher-jobs")
get "teaching-jobs-for-classics", to: redirect("classics-latin-teacher-jobs")
get "teaching-jobs-for-computing", to: redirect("ict-computer-science-teacher-jobs")
get "teaching-jobs-for-dance", to: redirect("dance-drama-music-teacher-jobs")
get "teaching-jobs-for-design-and-technology", to: redirect("design-technology-teacher-jobs")
get "teaching-jobs-for-drama", to: redirect("dance-drama-music-teacher-jobs")
get "teaching-jobs-for-economics", to: redirect("economics-business-studies-teacher-jobs")
get "teaching-jobs-for-engineering", to: redirect("design-technology-teacher-jobs")
get "teaching-jobs-for-english", to: redirect("english-media-studies-teacher-jobs")
get "teaching-jobs-for-food-technology", to: redirect("food-technology-teacher-jobs")
get "teaching-jobs-for-french", to: redirect("french-teacher-jobs")
get "teaching-jobs-for-geography", to: redirect("geography-teacher-jobs")
get "teaching-jobs-for-german", to: redirect("german-teacher-jobs")
get "teaching-jobs-for-health-and-social-care", to: redirect("health-relationships-social-care-teacher-jobs")
get "teaching-jobs-for-history", to: redirect("history-teacher-jobs")
get "teaching-jobs-for-humanities", to: redirect("politics-humanities-social-sciences-teacher-jobs")
get "teaching-jobs-for-ict", to: redirect("ict-computer-science-teacher-jobs")
get "teaching-jobs-for-languages", to: redirect("mfl-teacher-jobs")
get "teaching-jobs-for-law", to: redirect("economics-business-studies-teacher-jobs")
get "teaching-jobs-for-mandarin", to: redirect("mandarin-teacher-jobs")
get "teaching-jobs-for-mathematics", to: redirect("maths-teacher-jobs")
get "teaching-jobs-for-media-studies", to: redirect("english-media-studies-teacher-jobs")
get "teaching-jobs-for-music", to: redirect("dance-drama-music-teacher-jobs")
get "teaching-jobs-for-philosophy", to: redirect("psychology-philosophy-sociology-re-teacher-jobs")
get "teaching-jobs-for-physical-education", to: redirect("physical-education-teacher-jobs")
get "teaching-jobs-for-physics", to: redirect("physics-teacher-jobs")
get "teaching-jobs-for-politics", to: redirect("politics-humanities-social-sciences-teacher-jobs")
get "teaching-jobs-for-psychology", to: redirect("psychology-philosophy-sociology-re-teacher jobs")
get "teaching-jobs-for-relationships-and-sex-education", to: redirect("health-relationships-social-care-teacher-jobs")
get "teaching-jobs-for-religious-education", to: redirect("health-relationships-social-care-teacher-jobs")
get "teaching-jobs-for-science", to: redirect("science-teacher-jobs")
get "teaching-jobs-for-social-sciences", to: redirect("politics-humanities-social-sciences-teacher-jobs")
get "teaching-jobs-for-sociology", to: redirect("psychology-philosophy-sociology-re-teacher-jobs")
get "teaching-jobs-for-spanish", to: redirect("spanish-teacher-jobs")
get "teaching-jobs-for-statistics", to: redirect("maths-teacher-jobs")

# "Non-dominant" locations
REDIRECTED_LOCATION_LANDING_PAGES.each do |location, redirect|
  get "teaching-jobs-in-#{location.parameterize}", to: redirect("teaching-jobs-in-#{redirect.parameterize}")
end
