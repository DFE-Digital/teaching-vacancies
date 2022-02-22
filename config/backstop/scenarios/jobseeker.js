module.exports = [
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker my applications page",
    "url": "http://localhost:3000/jobseekers/job_applications",
    "readySelector": ".govuk-main-wrapper",
    "selectors": [
      "viewport"
    ]
  },
  // {
  //   "cookiePath": "config/backstop/cookies.json",
  //   "label": "Jobseeker view application page",
  //   "url": "http://localhost:3000/jobseekers/job_applications",
  //   "readySelector": ".govuk-main-wrapper",
  //   "clickSelector": ".card-component .govuk-link",
  //   "selectors": [
  //     "viewport"
  //   ]
  // },
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker saved jobs page",
    "url": "http://localhost:3000/jobseekers/saved_jobs",
    "readySelector": ".govuk-main-wrapper",
    "selectors": [
      "viewport"
    ]
  },
  {
    "cookiePath": "config/backstop/cookies.json",
    "label": "Jobseeker view account page",
    "url": "http://localhost:3000/jobseekers/account",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": ["cookies-banner-component"],
    "selectors": [
      "viewport"
    ]
  }
];
