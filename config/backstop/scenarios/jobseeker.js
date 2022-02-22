module.exports = [
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker my applications page",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobseekers/job_applications",
    "readySelector": ".govuk-main-wrapper",
    "selectors": [
      "viewport"
    ]
  },
  // {
  //   "cookiePath": "config/backstop/cookies.json",
  //   "label": "Jobseeker view application page",
  //   "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobseekers/job_applications",
  //   "readySelector": ".govuk-main-wrapper",
  //   "clickSelector": ".card-component .govuk-link",
  //   "selectors": [
  //     "viewport"
  //   ]
  // },
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker saved jobs page",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobseekers/saved_jobs",
    "readySelector": ".govuk-main-wrapper",
    "selectors": [
      "viewport"
    ]
  },
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker view account page",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobseekers/account",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": ["cookies-banner-component"],
    "selectors": [
      "viewport"
    ]
  }
];
